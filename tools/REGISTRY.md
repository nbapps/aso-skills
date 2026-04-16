# Tool Registry

Tools and integrations that ASO skills can use for real-time App Store data.

## Primary Stack

The skills rely on a small, composable stack of public and third-party sources:

| Source | Role | Setup |
|--------|------|-------|
| **[Astro MCP](integrations/astro.md)** | Keywords, rankings, ratings, search, suggestions, competitor extraction | MCP config |
| **[Sensor Tower (public)](integrations/sensor-tower.md)** | App metadata, screenshots, downloads & revenue estimates | No auth — public endpoint |
| **[iTunes Lookup](integrations/itunes-lookup.md)** | Release notes / What's New, current version, IAP flag | No auth — public endpoint |
| **[Apple RSS Reviews](integrations/apple-rss-reviews.md)** | User reviews (up to 500 most recent per country) | No auth — public feed |

> Market intelligence (movers, trending, featured, new releases) and first-party ASC data (exact downloads/revenue) are **not** covered by the current stack. Skills that depended on those are flagged below.

## Capability Matrix

| Capability | Tool / Endpoint | Integration Guide |
|-----------|-----------------|-------------------|
| App metadata (name, description, publisher, category, version) | Sensor Tower `GET /api/ios/apps?app_ids=:id` | [sensor-tower.md](integrations/sensor-tower.md) |
| Release notes / What's New | iTunes Lookup `GET /lookup?id=:id` | [itunes-lookup.md](integrations/itunes-lookup.md) |
| Screenshots (iPhone, iPad, icon) | Sensor Tower `GET /api/ios/apps?app_ids=:id` | [sensor-tower.md](integrations/sensor-tower.md) |
| Competitor screenshots (batch) | Sensor Tower `GET /api/ios/apps?app_ids=id1,id2,id3` | [sensor-tower.md](integrations/sensor-tower.md) |
| Downloads estimate (monthly) | Sensor Tower `humanized_worldwide_last_month_downloads` | [sensor-tower.md](integrations/sensor-tower.md) |
| Revenue estimate (monthly) | Sensor Tower `humanized_worldwide_last_month_revenue` | [sensor-tower.md](integrations/sensor-tower.md) |
| User reviews (most recent, by country) | Apple RSS `/{cc}/rss/customerreviews/id=:id/sortBy=mostRecent/json` | [apple-rss-reviews.md](integrations/apple-rss-reviews.md) |
| App ratings (current + history) | Astro `get_app_ratings` | [astro.md](integrations/astro.md) |
| App search | Astro `search_app_store` | [astro.md](integrations/astro.md) |
| App tracking setup | Astro `add_app`, `list_apps` | [astro.md](integrations/astro.md) |
| Track keywords (batch up to 100) | Astro `add_keywords` | [astro.md](integrations/astro.md) |
| Keyword rankings (current) | Astro `search_rankings` | [astro.md](integrations/astro.md) |
| Keyword rank trends (history + volatility + trend) | Astro `search_rankings` (`includeHistory`, `includeStatistics`) | [astro.md](integrations/astro.md) |
| Keyword popularity & difficulty | Astro `add_keywords` / `search_rankings` response | [astro.md](integrations/astro.md) |
| Keyword suggestions (AI) | Astro `get_keyword_suggestions` | [astro.md](integrations/astro.md) |
| Competitor keyword extraction | Astro `extract_competitors_keywords` | [astro.md](integrations/astro.md) |
| App's tracked keywords | Astro `get_app_keywords` | [astro.md](integrations/astro.md) |
| Keyword tags & notes (organization) | Astro `manage_tag`, `set_keyword_tag`, `set_keyword_note` | [astro.md](integrations/astro.md) |

## Not Currently Covered

These capabilities were part of the previous stack but have no drop-in replacement in the current one. Affected skills either degrade gracefully (run on general knowledge) or need a manual data source.

| Missing capability | Impact |
|--------------------|--------|
| Country chart rankings (top-free/paid/grossing by country) | `market-movers`, `market-pulse`, `app-store-featured` |
| Market movers (gainers/losers) | `market-movers`, `market-pulse`, `competitor-tracking` |
| Trending keywords (live) | `market-pulse`, `seasonal-aso` |
| Featured apps / editorial | `app-store-featured`, `market-pulse` |
| New releases feed | `market-pulse` |
| Downloads-to-top (rank → volume) | `market-movers`, `app-launch` |
| First-party ASC data (exact downloads/revenue/subs) | `asc-metrics` — use the official [App Store Connect API](integrations/app-store-connect.md) directly |
| In-app purchase list | `monetization-strategy`, `subscription-lifecycle` — IAP flag is available via iTunes Lookup, but not the full list |
| Review sentiment analysis (pre-computed) | `review-management`, `retention-optimization` — compute from RSS reviews in-skill |

## Skill → Tool Mapping

| Skill | Tools Used |
|-------|-----------|
| `aso-audit` | Astro `search_rankings`, `get_app_keywords`, `get_app_ratings` · Sensor Tower (metadata) · iTunes Lookup (What's New) |
| `keyword-research` | Astro `get_keyword_suggestions`, `search_rankings`, `add_keywords`, `extract_competitors_keywords` |
| `metadata-optimization` | Sensor Tower (metadata) · iTunes Lookup · Astro `get_app_keywords` |
| `competitor-analysis` | Astro `extract_competitors_keywords`, `search_rankings` · Sensor Tower (competitor batch: metadata, screenshots, downloads/revenue) |
| `screenshot-optimization` | Sensor Tower (screenshots + competitor screenshots) |
| `review-management` | Apple RSS reviews · Astro `get_app_ratings` (history) |
| `localization` | Astro `get_keyword_suggestions`, `search_rankings` (per store) · Sensor Tower (per-country metadata) |
| `app-launch` | Astro `search_app_store`, `get_keyword_suggestions` |
| `ua-campaign` | Astro `search_rankings`, `get_keyword_suggestions` · Sensor Tower (revenue/downloads benchmarks) |
| `apple-search-ads` | Astro `search_rankings`, `get_keyword_suggestions`, `add_keywords` |
| `app-store-featured` | Sensor Tower (metadata) — market/featured data **not covered** (degraded) |
| `retention-optimization` | Apple RSS reviews · Sensor Tower (downloads trend) |
| `monetization-strategy` | Sensor Tower (revenue/downloads) · Apple RSS reviews · iTunes Lookup (IAP flag) |
| `app-analytics` | Sensor Tower (downloads/revenue) · Astro `search_rankings` |
| `ab-test-store-listing` | Sensor Tower (screenshots, metadata) · Astro `get_app_ratings` |
| `app-marketing-context` | Sensor Tower (metadata) · Astro `get_app_keywords`, `search_app_store` |
| `market-movers` | **Not covered** — relies on general knowledge + Astro `search_app_store` |
| `market-pulse` | **Not covered** — relies on general knowledge + Astro `search_app_store` |
| `asc-metrics` | Official [App Store Connect API](integrations/app-store-connect.md) (JWT auth) |
| `seasonal-aso` | Astro `get_keyword_suggestions`, `search_rankings` |
| `in-app-events` | Astro `get_keyword_suggestions`, `search_rankings` · Sensor Tower (metadata) |
| `android-aso` | Apple RSS reviews (cross-ref only) · general knowledge (Play Store has no public API equivalent) |
| `onboarding-optimization` | Apple RSS reviews · Sensor Tower (downloads) |
| `rating-prompt-strategy` | Astro `get_app_ratings` (history) · Apple RSS reviews |
| `app-icon-optimization` | Sensor Tower (icon + competitor icons) |
| `subscription-lifecycle` | Sensor Tower (revenue) · Apple RSS reviews |
| `app-clips` | Astro `search_rankings` · Sensor Tower (metadata) |
| `competitor-tracking` | Astro `search_rankings`, `get_app_keywords`, `get_app_ratings` · Sensor Tower (metadata, downloads, revenue) · Apple RSS reviews |
| `crash-analytics` | Apple RSS reviews · Astro `get_app_ratings` |
| `press-and-pr` | Sensor Tower (metadata) · Astro `search_app_store` |

## Other Useful Tools

| Tool | Purpose | Integration |
|------|---------|-------------|
| **App Store Connect** | Official Apple analytics, releases, IAP management, first-party sales data | [app-store-connect.md](integrations/app-store-connect.md) |
| **RevenueCat** | Subscription analytics, paywall A/B testing | [revenuecat.md](integrations/revenuecat.md) |
| **Firebase** | In-app analytics, crash reporting, A/B testing | [firebase.md](integrations/firebase.md) |
