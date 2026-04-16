# iTunes Lookup — Release Notes & Current Version

Apple's free public lookup endpoint. Returns the same payload iTunes / App Store clients use for app detail pages. Most useful here for **release notes** ("What's New") and version metadata.

**Base URL:** `https://itunes.apple.com/lookup`

No authentication. Rate-limited by Apple (~20 req/min per IP, undocumented).

## Endpoint

```
GET https://itunes.apple.com/lookup?id=APP_ID&country=us
```

**Example:**
```bash
curl "https://itunes.apple.com/lookup?id=544007664&country=us"
```

## Response Structure

```json
{
  "resultCount": 1,
  "results": [
    {
      "trackId": 544007664,
      "trackName": "YouTube: Watch, Listen, Stream",
      "version": "21.15.04",
      "releaseNotes": "Bug fixes and performance improvements.",
      "currentVersionReleaseDate": "2026-04-13T...",
      "releaseDate": "2012-09-11T...",
      "description": "Full store description...",
      "primaryGenreName": "Photo & Video",
      "genres": ["Photo & Video", "Entertainment"],
      "averageUserRating": 4.67,
      "userRatingCount": 170312000,
      "averageUserRatingForCurrentVersion": 4.67,
      "userRatingCountForCurrentVersion": 46800000,
      "price": 0,
      "formattedPrice": "Free",
      "trackViewUrl": "https://apps.apple.com/us/app/...",
      "artworkUrl512": "...",
      "screenshotUrls": [...],
      "ipadScreenshotUrls": [...],
      "languageCodesISO2A": ["EN", "FR", ...],
      "fileSizeBytes": "...",
      "minimumOsVersion": "...",
      "supportedDevices": [...]
    }
  ]
}
```

## Key Fields by Use Case

| Use case | Field |
|----------|-------|
| Release notes / What's New | `releaseNotes` |
| Current version | `version` |
| Last update date | `currentVersionReleaseDate` |
| Full description | `description` |
| Genre / category | `primaryGenreName`, `genres` |
| Languages supported | `languageCodesISO2A` |
| Price / free | `price`, `formattedPrice` |
| Min OS / device support | `minimumOsVersion`, `supportedDevices` |
| File size | `fileSizeBytes` |

> Sensor Tower's public endpoint covers most of these too, but **release notes** and the **full language list** are iTunes Lookup's differentiators.

## Batch Lookup

Comma-separate IDs:

```bash
curl "https://itunes.apple.com/lookup?id=544007664,1459969523&country=us"
```

## Per-Country Metadata

Pass `country=` with any ISO country code to get localized metadata (title, description, screenshots per store):

```bash
curl "https://itunes.apple.com/lookup?id=544007664&country=fr"
curl "https://itunes.apple.com/lookup?id=544007664&country=jp"
```

Use in `localization` to audit per-country listings.

## Use in Skills

| Skill | Why |
|-------|-----|
| `aso-audit` | Pull `releaseNotes`, `currentVersionReleaseDate` for the freshness factor |
| `metadata-optimization` | Current full description / languages as baseline |
| `competitor-tracking` | Diff `releaseNotes` + `version` + `currentVersionReleaseDate` week-over-week |
| `localization` | Per-country metadata audit |
| `app-marketing-context` | Seed version info, min OS, supported devices |
| `monetization-strategy` | Price + formattedPrice baseline |

## Limitations

- **iOS only.**
- **Rate limited** — cache aggressively; one call per app per session is usually enough.
- **Not the same as the store web view** — some fields visible on apps.apple.com (e.g., ratings by country) aren't in this payload.
