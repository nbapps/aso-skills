#!/usr/bin/env bash
# cached-curl.sh — thin caching wrapper around curl.
#
# Caches GET responses on disk under ~/.cache/aso/<sha1(url+auth)>.<ext>
# and returns the cached body when it is still within TTL, otherwise fetches
# fresh, writes the cache, and returns the new body.
#
# Usage:
#   tools/cached-curl.sh <ttl-seconds> <url> [curl-args...]
#
# Examples:
#   # 1 day TTL, plain GET
#   tools/cached-curl.sh 86400 "https://app.sensortower.com/api/ios/apps?app_ids=1456241169"
#
#   # With UA header (required by apps.apple.com)
#   tools/cached-curl.sh 86400 "https://apps.apple.com/us/app/_/id1456241169" -A "Mozilla/5.0"
#
#   # With ASC Bearer (JWT expires in 20 min; cache the response body longer)
#   JWT=$(tools/asc-jwt.sh)
#   tools/cached-curl.sh 3600 "https://api.appstoreconnect.apple.com/v1/apps" \
#     -H "Authorization: Bearer $JWT"
#
# Cache layout:
#   ~/.cache/aso/<sha1>.body     cached response body
#   ~/.cache/aso/<sha1>.meta     HTTP code + Content-Type on one line
#
# Environment variables:
#   ASO_CACHE_DIR   override cache dir (default: ~/.cache/aso)
#   ASO_CACHE_OFF   set to 1 to bypass cache (fetch + write only)
#   ASO_CACHE_DRY   set to 1 to read cache but never fetch (returns empty on miss)

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: cached-curl.sh <ttl-seconds> <url> [curl-args...]" >&2
  exit 2
fi

TTL="$1"; shift
URL="$1"; shift

CACHE_DIR="${ASO_CACHE_DIR:-$HOME/.cache/aso}"
mkdir -p "$CACHE_DIR"

# Hash the URL + any auth-bearing args so different auths get distinct entries.
# We pass all curl args through as-is; the hash covers the url + the arg string.
KEY_INPUT="$URL|$*"
KEY=$(printf '%s' "$KEY_INPUT" | openssl dgst -sha1 -r | awk '{print $1}')
BODY_FILE="$CACHE_DIR/$KEY.body"
META_FILE="$CACHE_DIR/$KEY.meta"

now=$(date +%s)

# Cache hit: fresh body file exists, age < TTL, not bypassed.
if [[ "${ASO_CACHE_OFF:-0}" != "1" && -f "$BODY_FILE" ]]; then
  mtime=$(stat -f %m "$BODY_FILE" 2>/dev/null || stat -c %Y "$BODY_FILE")
  age=$(( now - mtime ))
  if (( age < TTL )); then
    cat "$BODY_FILE"
    exit 0
  fi
fi

# Dry mode: don't hit the network, just signal miss with empty output + nonzero exit.
if [[ "${ASO_CACHE_DRY:-0}" == "1" ]]; then
  exit 3
fi

# Fetch fresh. Write body + HTTP status to a single response stream.
tmp_body=$(mktemp "$BODY_FILE.XXXXXX")
http_code=$(curl -sS --output "$tmp_body" --write-out '%{http_code}' "$URL" "$@" || true)

if [[ "$http_code" =~ ^2 ]]; then
  mv "$tmp_body" "$BODY_FILE"
  printf '%s\n' "$http_code" > "$META_FILE"
  cat "$BODY_FILE"
else
  # Failure: keep any older cache, emit body to stderr for debugging, exit nonzero.
  echo "cached-curl: HTTP $http_code for $URL" >&2
  cat "$tmp_body" >&2
  rm -f "$tmp_body"
  exit 1
fi
