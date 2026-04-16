#!/usr/bin/env bash
# asc-jwt.sh — emit a short-lived ES256 JWT for the App Store Connect API.
#
# Reads credentials from ~/.config/aso/config.env and the PEM key from
# ~/.config/aso/AuthKey_${ASC_KEY_ID}.p8 (naming convention — do not rename
# the .p8 file that App Store Connect downloads).
#
# Dependencies: bash, openssl, python3 (stdlib only — no pip install needed).
#
# Usage:
#   JWT=$(tools/asc-jwt.sh)
#   curl -H "Authorization: Bearer $JWT" https://api.appstoreconnect.apple.com/v1/apps
#
# The generated JWT has a 20-minute expiry (Apple's max). Regenerate on each
# burst of requests rather than reusing across long runs.

set -euo pipefail

CONFIG="${ASC_CONFIG:-$HOME/.config/aso/config.env}"
if [[ ! -r "$CONFIG" ]]; then
  echo "asc-jwt: $CONFIG not found or unreadable" >&2
  echo "         see README → 'First-Party ASC Data → Setup' to create it" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG"

: "${ASC_KEY_ID:?ASC_KEY_ID missing in $CONFIG}"
: "${ASC_ISSUER_ID:?ASC_ISSUER_ID missing in $CONFIG}"

KEY_PATH="${ASC_KEY_PATH:-$HOME/.config/aso/AuthKey_${ASC_KEY_ID}.p8}"
if [[ ! -r "$KEY_PATH" ]]; then
  echo "asc-jwt: private key $KEY_PATH not found or unreadable" >&2
  echo "         expected convention: ~/.config/aso/AuthKey_\${ASC_KEY_ID}.p8" >&2
  exit 1
fi

# Base64url (no padding, URL-safe alphabet)
b64url() { openssl base64 -e -A | tr -d '=' | tr '/+' '_-'; }

HEADER=$(printf '{"alg":"ES256","kid":"%s","typ":"JWT"}' "$ASC_KEY_ID" | b64url)
NOW=$(date +%s)
EXP=$((NOW + 1200))   # 20 min — Apple's maximum
PAYLOAD=$(printf '{"iss":"%s","iat":%d,"exp":%d,"aud":"appstoreconnect-v1"}' \
            "$ASC_ISSUER_ID" "$NOW" "$EXP" | b64url)

SIGNING_INPUT="$HEADER.$PAYLOAD"

# openssl produces ECDSA signatures in DER format; ES256 JWTs require raw
# R||S (64 bytes for P-256). Convert via python stdlib (no pip deps).
SIG=$(printf '%s' "$SIGNING_INPUT" \
      | openssl dgst -sha256 -sign "$KEY_PATH" -binary \
      | python3 -c '
import sys, base64
der = sys.stdin.buffer.read()
i = 0
assert der[i] == 0x30; i += 1
if der[i] & 0x80: i += 1 + (der[i] & 0x7f)
else: i += 1
assert der[i] == 0x02; i += 1
rlen = der[i]; i += 1
r = der[i:i+rlen]; i += rlen
assert der[i] == 0x02; i += 1
slen = der[i]; i += 1
s = der[i:i+slen]
r = r.lstrip(b"\x00").rjust(32, b"\x00")
s = s.lstrip(b"\x00").rjust(32, b"\x00")
print(base64.urlsafe_b64encode(r + s).rstrip(b"=").decode())
')

printf '%s.%s\n' "$SIGNING_INPUT" "$SIG"
