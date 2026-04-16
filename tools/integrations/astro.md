# Astro — Keyword Tracking & Rankings

Real-time App Store keyword rankings, suggestions, and competitor keyword extraction via MCP.

**Website:** [astroaso.com](https://astroaso.com)

## MCP Setup

Add to your Claude Code or Cursor MCP config:

```json
{
  "mcpServers": {
    "astro": {
      "url": "https://mcp.astroaso.com/mcp",
      "headers": {
        "Authorization": "Bearer your_astro_token"
      }
    }
  }
}
```

> Astro is tracker-based: you first register the apps and keywords you care about (`add_app`, `add_keywords`), and subsequent calls return live and historical data for those tracked items.

## Tools

### `list_apps`

List all tracked applications with keyword counts and stores.

**Use in skills:** every skill — quick way to find a tracked app before other calls.

### `add_app`

Add an app to tracking. Requires the numeric App Store ID (use `search_app_store` to find it) or creates a temporary placeholder for unpublished apps.

**Inputs:** `appStoreId`, `platform` (`iphone`/`ipad`/`mac`/`appletv`/`realityDevice`), or `temporary: true` + optional `name`.

**Use in skills:** `app-launch`, `app-marketing-context` (initial onboarding).

### `search_app_store`

Search the App Store by keyword. Returns ranked apps with details. Pass `appId` to include your app's ranking position.

**Inputs:** `keyword` (required), `store` (required, e.g. `us`, `uk`, `it`), `appId`, `limit` (max 100), `platform`.

**Use in skills:** `app-marketing-context`, `competitor-analysis`, `app-launch`, `press-and-pr`.

### `add_keywords`

Track up to 100 keywords for an app. Fetches ranking, popularity, and difficulty in batch.

**Inputs:** `keywords` (array, max 100), `store`, `appId` or `appName`, `platform`.

**Use in skills:** `keyword-research`, `apple-search-ads`.

### `get_app_keywords`

Return all keywords tracked for a given app.

**Inputs:** `appId` or `appName`, `store` (optional).

**Use in skills:** `aso-audit`, `competitor-tracking`, `app-marketing-context`.

### `search_rankings`

Current ranking, difficulty, popularity, and metadata for a keyword. Set `includeHistory: true` + `period` (`week`/`month`/`year`/`all`) for trends, and `includeStatistics: true` for volatility + trend direction.

**Inputs:** `keyword` (required), `store` (required), `appId`, `appName`, `includeHistory`, `daysBack`, `period`, `includeStatistics`.

**Use in skills:** `aso-audit`, `keyword-research`, `competitor-tracking`, `apple-search-ads`, `app-clips`, `seasonal-aso`.

### `get_keyword_suggestions`

AI-powered keyword suggestions for an app. Returns suggestions with popularity, difficulty, and app count.

**Inputs:** `store` (required), `appId` or `appName`, `highPopularity` (default true).

**Use in skills:** `keyword-research`, `seasonal-aso`, `in-app-events`, `localization`, `ua-campaign`, `apple-search-ads`, `android-aso`.

### `extract_competitors_keywords`

Extract keyword ideas from competitor apps ranking for a **tracked** keyword. Generates word combinations, fetches popularity, returns keywords with `popularity > 5` sorted by score.

**Inputs:** `keyword` (must already be tracked), `store`.

**Use in skills:** `keyword-research`, `competitor-analysis`.

### `get_app_ratings`

Current average rating and review count per store. Set `includeHistory: true` for the full rating history.

**Inputs:** `appId` or `appName`, `store`, `includeHistory`.

**Use in skills:** `aso-audit`, `review-management`, `rating-prompt-strategy`, `crash-analytics`, `competitor-tracking`, `ab-test-store-listing`.

### `manage_tag`

List / create / update tags used to organize tracked keywords. Colors: red, orange, yellow, green, blue, purple, gray.

**Inputs:** `action` (`list`/`create`/`update`), `name`, `color`, `newName`.

**Use in skills:** `keyword-research`, `competitor-tracking` (organizational).

### `set_keyword_tag`

Add or remove an existing tag on a tracked keyword.

**Inputs:** `keyword`, `tag`, `action` (`add`/`remove`), `appId`/`appName`, `store`.

### `set_keyword_note`

Set, update, or delete a note on a tracked keyword. Pass an empty `note` to delete.

**Inputs:** `keyword`, `note`, `appId`/`appName`, `store`.

## Common Patterns

### Bootstrap a new tracked app

```
1. search_app_store → find the App Store ID
2. add_app → register it for tracking
3. get_keyword_suggestions → seed initial keyword list
4. add_keywords → track the seeded list
5. search_rankings (includeHistory, includeStatistics) → watch movement
```

### Competitor keyword mining

```
1. Ensure the seed keyword is tracked (add_keywords)
2. extract_competitors_keywords → word combinations from competitor rankings
3. add_keywords → promote the high-value ones to tracking
```

### Rating health check

```
get_app_ratings (includeHistory: true) → detect rating drops
→ paired with scraped App Store reviews to explain the drop
```

## What Astro Does NOT Cover

- App metadata (title, description, screenshots) → use Sensor Tower
- Release notes / What's New → use iTunes Lookup
- User reviews (text) → scrape `apps.apple.com` (see [apple-reviews-scrape.md](apple-reviews-scrape.md))
- Download / revenue estimates → use Sensor Tower
- First-party ASC data → use the official App Store Connect API
- Market movers, trending keywords, featured apps, chart rankings by country → not covered
