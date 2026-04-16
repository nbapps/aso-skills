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

## Response Fields

| Field | Purpose |
|-------|---------|
| `app_id` | Numeric App Store ID |
| `name` | App title |
| `publisher_name`, `publisher_id` | Publisher info |
| `short_description`, `description` | Store listing copy |
| `version`, `release_date`, `updated_date` | Version / release metadata |
| `price`, `currency` | Price (0 for free) |
| `categories` | Apple category IDs |
| `content_rating`, `advisories` | Age / content flags |
| `icon_url`, `screenshot_url`, `ipad_screenshot_url` | Image assets |
| `current_version_rating`, `current_version_rating_count` | Current-version rating snapshot |
| `global_rating`, `global_rating_count` | Lifetime rating snapshot |
| `humanized_worldwide_last_month_downloads` | **Estimated** monthly downloads |
| `humanized_worldwide_last_month_revenue` | **Estimated** monthly revenue |
| `has_in_app_purchases` | IAP flag (list not returned) |
| `supports_apple_watch`, `supports_imessage` | Platform flags |

> The `humanized_*` fields are Sensor Tower's market estimates — treat as directional, not exact. For first-party truth, use the App Store Connect API.

## Use in Skills

| Skill | Why |
|-------|-----|
| `aso-audit` | Metadata snapshot (title, description, category, version) |
| `metadata-optimization` | Baseline before rewriting title/subtitle/description |
| `competitor-analysis` | Batch competitor pull (metadata + screenshots + downloads + revenue in one call) |
| `screenshot-optimization` | Current screenshot URLs |
| `app-icon-optimization` | Icon URL + competitor icons for side-by-side |
| `ab-test-store-listing` | Current screenshots + metadata as control |
| `app-marketing-context` | Seed the context doc |
| `monetization-strategy` | Revenue / downloads benchmark |
| `ua-campaign` | Revenue / downloads benchmarks for payback math |
| `retention-optimization` | Downloads trend context |
| `subscription-lifecycle` | Revenue trend context |
| `competitor-tracking` | Weekly metadata diff + revenue/downloads delta |
| `press-and-pr` | App info for pitch drafting |

## Common Patterns

### Batch competitor pull

```bash
curl "https://app.sensortower.com/api/ios/apps?app_ids=544007664,1459969523,1278508568"
```

Returns an array with one object per app — metadata, screenshots, and estimates for all three in a single request.

### Paired with iTunes Lookup for release notes

Sensor Tower doesn't return release notes. For "What's New":

```bash
curl "https://itunes.apple.com/lookup?id=544007664&country=us"
# → releaseNotes field
```

See [itunes-lookup.md](itunes-lookup.md).

## Limitations

- **iOS only** — no Google Play equivalent on this endpoint.
- **Estimates** — downloads/revenue are modeled, not exact. Apple's ASC API is the only first-party source.
- **No IAP list** — only a boolean flag. Use the App Store Connect API if you need the full IAP catalog.
- **No reviews text** — use Apple RSS (`apple-rss-reviews.md`).
- **Undocumented rate limits** — cache responses, avoid hammering.
