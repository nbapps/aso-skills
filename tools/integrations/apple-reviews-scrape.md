# Apple App Store Reviews — Web Page Scrape

Apple's `itunes.apple.com/*/rss/customerreviews/*` public feed returns **0 entries** for virtually every app as of 2025+ — it is effectively deprecated. This guide uses the public App Store web page (`apps.apple.com`) instead: it server-side-renders ~40 reviews per country into an embedded JSON blob, which is trivial to parse.

**Base URL:** `https://apps.apple.com/{country}/app/_/id{APP_ID}`

- No authentication
- No API key
- ~40 reviews per request, per country
- Served as HTML with an embedded `<script type="application/json">` block

## Endpoint

```
GET https://apps.apple.com/{country}/app/_/id{APP_ID}
```

- `country` — two-letter ISO code (`us`, `fr`, `jp`, `gb`, ...)
- `APP_ID` — numeric App Store ID

The URL slug between `/app/` and `/id{ID}` is ignored by Apple — any value (including `_`) works.

**Always send a real User-Agent** — default `curl/*` gets a minimal page without the SSR payload.

```bash
curl -sL -A "Mozilla/5.0" \
  "https://apps.apple.com/us/app/_/id1456241169" \
  -o /tmp/app.html
```

## Extraction

Reviews are embedded as a single `<script type="application/json">` block containing the full page state. Inside it, each review is an object with `"$kind": "Review"`.

### Python

```python
import re, json, urllib.request

def fetch_reviews(app_id: str, country: str = "us") -> list[dict]:
    url = f"https://apps.apple.com/{country}/app/_/id{app_id}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    html = urllib.request.urlopen(req).read().decode("utf-8")

    m = re.search(
        r'<script[^>]*type="application/json"[^>]*>(.*?)</script>',
        html, re.DOTALL,
    )
    if not m:
        return []
    data = json.loads(m.group(1))

    reviews = []
    def walk(node):
        if isinstance(node, dict):
            if node.get("$kind") == "Review":
                reviews.append(node)
            for v in node.values():
                walk(v)
        elif isinstance(node, list):
            for v in node:
                walk(v)

    walk(data)
    return reviews

# Example
for r in fetch_reviews("1456241169", "us"):
    print(r["rating"], r["title"], "—", r["reviewerName"])
```

## Review Object Shape

```json
{
  "$kind": "Review",
  "id": "8257432300",
  "title": "Great App",
  "rating": 5,
  "date": "2022-01-19T08:41:48.000Z",
  "dateText": "edited * null *",
  "contents": "Full review body with newlines and emoji…",
  "reviewerName": "Oktober Owlet",
  "dateAuthorText": "edited * null * · Oktober Owlet",
  "response": {
    "$kind": "Response",
    "id": "19112589",
    "contents": "Developer response text…",
    "date": "2020-11-15T09:12:51.000Z",
    "dateText": "* null *"
  }
}
```

### Key fields

| Field | Purpose |
|-------|---------|
| `rating` | 1–5 stars (integer) |
| `title` | Review headline |
| `contents` | Full review body (may contain `\n`, emoji) |
| `reviewerName` | Reviewer nickname |
| `date` | ISO timestamp |
| `response` | Developer reply (nullable) |

## Per-Country Reviews

Swap the country segment — each country returns its own batch:

```bash
curl -sL -A "Mozilla/5.0" "https://apps.apple.com/us/app/_/id1456241169"
curl -sL -A "Mozilla/5.0" "https://apps.apple.com/fr/app/_/id1456241169"
curl -sL -A "Mozilla/5.0" "https://apps.apple.com/jp/app/_/id1456241169"
```

Pair with `astro.get_app_ratings` to correlate rating drops with review content per country.

## Use in Skills

| Skill | Why |
|-------|-----|
| `review-management` | Primary data source — sentiment, themes, HEAR-framework responses |
| `retention-optimization` | Mine reasons for churn / uninstall complaints |
| `crash-analytics` | Detect crash spikes via reviews mentioning crashes / freezes |
| `rating-prompt-strategy` | Pair with rating history to find version-specific issues |
| `onboarding-optimization` | First-run friction mentioned in low-rated reviews |
| `subscription-lifecycle` | Complaints about pricing / trial / cancellation flow |
| `competitor-tracking` | Weekly watch on competitor reviews for emerging issues |

## Common Patterns

### Sentiment triage

```
Fetch the SSR batch (≈40 reviews)
→ split by rating (1–2 vs 4–5)
→ cluster themes in the negative bucket
→ output: top 3 recurring complaints + version correlation (use iTunes Lookup for version release dates)
```

### Polarity check

Most App Store pages render mostly 5-star and 1-star reviews — App Store's editorial curation favors the extremes. If you need mid-rating depth, paginate across countries or use App Store Connect API (your own app only).

## Caching

The `apps.apple.com` page is heavy (~800 KB) and scraping it repeatedly looks suspicious. Use [`tools/cached-curl.sh`](../cached-curl.sh) with a 6h TTL:

```bash
tools/cached-curl.sh 21600 \
  "https://apps.apple.com/us/app/_/id1456241169" \
  -A "Mozilla/5.0" > /tmp/mqrg-us.html

# Then parse /tmp/mqrg-us.html as usual — or directly pipe:
tools/cached-curl.sh 21600 "https://apps.apple.com/us/app/_/id1456241169" -A "Mozilla/5.0" \
  | python3 -c 'import re, json, sys
html = sys.stdin.read()
m = re.search(r"<script[^>]*type=\"application/json\"[^>]*>(.*?)</script>", html, re.DOTALL)
data = json.loads(m.group(1))
reviews = []
def walk(n):
    if isinstance(n, dict):
        if n.get("$kind") == "Review": reviews.append(n)
        for v in n.values(): walk(v)
    elif isinstance(n, list):
        for v in n: walk(v)
walk(data)
for r in reviews:
    print(r["rating"], "★", r.get("title"), "—", r.get("reviewerName"))
'
```

6h keeps the signal warm without hammering Apple. Drop to 1h only if you are actively monitoring a rating crisis.

## Limitations

- **~40 reviews per call, per country.** Apple does not return the full review list in SSR. The web page lazy-loads more via an authenticated AMP API (`amp-api.apps.apple.com`), which needs a Bearer token harvested from the page JS — fragile and subject to break.
- **Polarity bias** — the SSR sample skews toward 5-star and 1-star; few 2–4-star reviews.
- **iOS only** — no equivalent scraping target on Google Play (Play's listing page does not SSR reviews in the same way; use `google-play-scraper` npm/pip libs or the Play Developer API).
- **Public HTML contract** — Apple can change the embedded JSON shape at any time. Pin the walker (search for `$kind == "Review"`) rather than depending on the exact path.
- **Rate limiting** — undocumented. Cache per-country, throttle to ≤1 req/sec.
- **User-Agent required** — without a browser-like UA, Apple returns a minimal page without the JSON payload.
