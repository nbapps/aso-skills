# Sensor Tower (Public) — App Metadata & Market Estimates

Free, unauthenticated endpoint returning app metadata, screenshots, and monthly downloads / revenue estimates.

**Base URL:** `https://app.sensortower.com/api/ios/apps`

> This is the public endpoint that powers Sensor Tower's web app. No API key required. Rate limits are undocumented — treat it as best-effort and cache aggressively.

## Endpoint

```
GET https://app.sensortower.com/api/ios/apps?app_ids=APP_ID[,APP_ID2,...]
```

`app_ids` accepts a comma-separated list — batch up to several competitors in one request.

**Example:**
```bash
curl "https://app.sensortower.com/api/ios/apps?app_ids=544007664"
```

## Response Shape

```json
{
  "apps": [
    { "app_id": 544007664, "name": "...", ... }
  ]
}
```

The array lives under `apps`, **not** at the top level. One object per requested ID, in the order requested.

## Response Fields

### Identity & metadata

| Field | Purpose |
|-------|---------|
| `app_id` | Numeric App Store ID |
| `bundle_id` | Reverse-DNS bundle id |
| `name`, `humanized_name` | App title |
| `subtitle` | Subtitle (30-char line under the name) |
| `short_description` | Short description (Play-style — often empty on iOS) |
| `description` | Full store description |
| `promo_text` | Promotional text (170 chars) |
| `publisher_name`, `publisher_id`, `publisher_profile_url` | Publisher |
| `publisher_country`, `publisher_address`, `publisher_email` | Publisher detail |
| `version` | Current version number |
| `release_date` | Original release date |
| `country_release_date` | Release date for the canonical country |
| `updated_date` | Last update date |
| `price`, `formatted_price` | 0 for free |
| `categories` | Apple category IDs (integers) |
| `content_rating`, `advisories` | Age / content flags |
| `supported_languages` | Array of language codes |
| `valid_countries` | Array of countries where the app is available |
| `canonical_country` | Default country used for the returned payload |
| `top_countries` | Array of top-performing country codes (e.g. `["US","GB","PH"]`) |

### Ratings

| Field | Purpose |
|-------|---------|
| `rating` | Lifetime average rating (float) |
| `rating_count` | Lifetime rating count |
| `rating_for_current_version` | Average for the current version |
| `rating_count_for_current_version` | Rating count for the current version |
| `global_rating_count` | Alternate global count (may differ from `rating_count`) |

### Assets

| Field | Purpose |
|-------|---------|
| `icon_url` | App icon |
| `screenshot_urls` | Array of iPhone screenshot URLs |
| `tablet_screenshot_urls` | Array of iPad / tablet screenshot URLs |
| `feature_graphic` | Feature graphic (usually null on iOS, present on Android) |
| `imessage_icon` | iMessage extension icon |

### Distribution estimates

| Field | Purpose |
|-------|---------|
| `humanized_worldwide_last_month_downloads` | **Estimated** monthly downloads — returns an object: `{ string: "< 5k", downloads: 1000, downloads_rounded: 5, prefix: "< ", units: "k" }` |
| `humanized_worldwide_last_month_revenue` | **Estimated** monthly revenue — same shape as above but with `revenue` / `revenue_rounded` keys |

> The `humanized_*` fields are Sensor Tower's market estimates — treat as directional, not exact. For first-party truth, use the App Store Connect API.

### Platform & capability flags

| Field | Purpose |
|-------|---------|
| `in_app_purchases` | **Boolean** — `true` if the app has IAPs. The list is **not** returned. |
| `apple_watch_enabled` | Apple Watch support |
| `imessage_enabled` | iMessage extension support |
| `permissions` | Declared privacy permissions |
| `active` | Whether the listing is live |

### Links

| Field | Purpose |
|-------|---------|
| `url`, `app_view_url` | App Store links |
| `website_url`, `support_url`, `privacy_policy_url`, `eula_url` | Publisher-declared URLs |

## Use in Skills

| Skill | Why |
|-------|-----|
| `aso-audit` | Metadata snapshot (title, subtitle, description, category, version, screenshots) |
| `metadata-optimization` | Baseline before rewriting title / subtitle / description / promo text |
| `competitor-analysis` | Batch competitor pull — metadata + screenshots + downloads + revenue in one call |
| `screenshot-optimization` | Current `screenshot_urls` + `tablet_screenshot_urls` |
| `app-icon-optimization` | Icon URL + competitor icons for side-by-side |
| `ab-test-store-listing` | Current screenshots + metadata as control |
| `app-marketing-context` | Seed the context doc |
| `monetization-strategy` | Revenue / downloads benchmark |
| `ua-campaign` | Revenue / downloads benchmarks for payback math |
| `retention-optimization` | Downloads trend context |
| `subscription-lifecycle` | Revenue trend context |
| `competitor-tracking` | Weekly metadata diff + revenue/downloads delta |
| `press-and-pr` | App info for pitch drafting |
| `localization` | `supported_languages` + `valid_countries` + `top_countries` baseline |

## Common Patterns

### Batch competitor pull

```bash
curl "https://app.sensortower.com/api/ios/apps?app_ids=544007664,1459969523,1278508568" \
  | jq '.apps[] | {app_id, name, rating, rating_count, dl: .humanized_worldwide_last_month_downloads.string, rev: .humanized_worldwide_last_month_revenue.string}'
```

Returns one object per app — metadata, screenshots, and estimates for all three in a single request.

### Paired with iTunes Lookup for release notes

Sensor Tower doesn't return release notes. For "What's New":

```bash
curl "https://itunes.apple.com/lookup?id=544007664&country=us"
# → releaseNotes field
```

See [itunes-lookup.md](itunes-lookup.md).

## Limitations

- **iOS only** — no Google Play equivalent on this endpoint.
- **Estimates** — downloads/revenue are modeled buckets (e.g. `"< 5k"`), not exact numbers. Apple's ASC API is the only first-party source.
- **No IAP list** — only a boolean flag (`in_app_purchases`). Use the App Store Connect API for the full catalog.
- **No reviews** — use scraping via [apple-reviews-scrape.md](apple-reviews-scrape.md).
- **Undocumented rate limits** — cache responses, avoid hammering.
- **Humanized buckets for small apps** — apps below ~5k downloads/month return the `< 5k` bucket with no finer granularity.
