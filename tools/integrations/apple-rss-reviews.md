# Apple RSS Reviews — Public User Reviews

Apple's free public review feed. Returns up to 500 most-recent customer reviews per country, no authentication.

**Base URL:** `https://itunes.apple.com/{country}/rss/customerreviews/`

## Endpoint

```
GET https://itunes.apple.com/{country}/rss/customerreviews/id={APP_ID}/sortBy={sort}/page={page}/json
```

- `country` — ISO country code, e.g. `us`, `fr`, `jp`, `gb`
- `APP_ID` — numeric App Store ID
- `sort` — `mostRecent` or `mostHelpful`
- `page` — 1..10 (50 reviews per page → 500 max)

**Example:**
```bash
curl "https://itunes.apple.com/us/rss/customerreviews/id=544007664/sortBy=mostRecent/page=1/json"
```

XML variant also exists (`/xml` suffix) — prefer JSON for ease of parsing.

## Response Structure

```json
{
  "feed": {
    "entry": [
      {
        "author": { "name": { "label": "..." }, "uri": { "label": "..." } },
        "updated": { "label": "2026-04-10T12:34:56-07:00" },
        "im:rating": { "label": "1" },
        "im:version": { "label": "21.15.04" },
        "title": { "label": "Short review title" },
        "content": { "label": "Full review body..." },
        "im:voteSum": { "label": "42" },
        "im:voteCount": { "label": "58" }
      }
    ]
  }
}
```

First `entry` in the feed is app metadata, not a review — skip it or filter on presence of `im:rating`.

## Key Fields

| Field | Purpose |
|-------|---------|
| `im:rating.label` | 1–5 stars |
| `title.label` | Review headline |
| `content.label` | Review body |
| `im:version.label` | App version reviewed |
| `updated.label` | Timestamp |
| `author.name.label` | Reviewer nickname |
| `im:voteSum.label` / `im:voteCount.label` | Helpfulness votes |

## Paging to 500

Pages 1–10, 50 reviews each:

```bash
for p in 1 2 3 4 5 6 7 8 9 10; do
  curl "https://itunes.apple.com/us/rss/customerreviews/id=$APP_ID/sortBy=mostRecent/page=$p/json"
done
```

## Per-Country Reviews

Swap the country segment:

```bash
curl "https://itunes.apple.com/fr/rss/customerreviews/id=$APP_ID/sortBy=mostRecent/page=1/json"
curl "https://itunes.apple.com/jp/rss/customerreviews/id=$APP_ID/sortBy=mostRecent/page=1/json"
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
| `android-aso` | Cross-reference iOS complaints when Play Store is the target (no equivalent public feed on Android) |
| `competitor-tracking` | Weekly watch on competitor reviews for emerging issues |

## Common Patterns

### Sentiment triage

```
Fetch pages 1-2 (100 most recent)
→ split by rating (1-2 vs 4-5)
→ cluster themes in the negative bucket
→ output: top 3 recurring complaints + version correlation
```

### Version issue detection

```
Fetch pages 1-5 (250 most recent)
→ group by im:version
→ find versions with avg rating drop
→ cross-check with iTunes Lookup currentVersionReleaseDate
```

## Limitations

- **Max 500 reviews per country, per sort order.** Older reviews are not retrievable.
- **No language filter** — reviews are whatever language users wrote.
- **No filter for critical / favorable** — only `mostRecent` / `mostHelpful`. Filter client-side on `im:rating`.
- **iOS only** — no equivalent public feed on Google Play.
- **Rate limit** undocumented — cache per-country, per-page.
