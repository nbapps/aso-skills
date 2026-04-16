# Tool Registry

Tools and integrations that ASO skills can use for real-time App Store data.

## Primary Stack

The skills rely on a small, composable stack of public and third-party sources:

| Source | Role | Setup |
|--------|------|-------|
| **[Astro MCP](integrations/astro.md)** | Keywords, rankings, ratings, search, suggestions, competitor extraction | MCP config |
| **[Sensor Tower (public)](integrations/sensor-tower.md)** | App metadata, screenshots, downloads & revenue estimates | No auth — public endpoint |
| **[iTunes Lookup](integrations/itunes-lookup.md)** | Release notes / What's New, current version, IAP flag | No auth — public endpoint |
| **[App Store reviews (web scrape)](integrations/apple-reviews-scrape.md)** | User reviews scraped from `apps.apple.com` SSR (≈40 per country) | No auth — public HTML |

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
| User reviews (most recent, by country) | Scrape `https://apps.apple.com/{cc}/app/_/id:id` (SSR JSON) | [apple-reviews-scrape.md](integrations/apple-reviews-scrape.md) |
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

## Helpers

Two shell scripts in `tools/` reduce boilerplate and keep rate-limit pressure down. Both are zero-dep (bash + openssl + python3 stdlib + curl).

| Helper | Purpose |
|--------|---------|
| [`tools/asc-jwt.sh`](asc-jwt.sh) | Reads `~/.config/aso/config.env` + the `.p8` key, emits a short-lived (20 min) ES256 JWT for the App Store Connect API on stdout. `JWT=$(tools/asc-jwt.sh)`. |
| [`tools/cached-curl.sh`](cached-curl.sh) | `curl` wrapper that caches GET responses on disk at `~/.cache/aso/<sha1>.body`. Usage: `tools/cached-curl.sh <ttl-sec> <url> [curl-args...]`. Env: `ASO_CACHE_OFF=1` bypasses, `ASO_CACHE_DRY=1` reads cache only. |

### Recommended TTLs per source

| Source | TTL | Reasoning |
|--------|-----|-----------|
| Sensor Tower `/api/ios/apps` | **86400** (1d) | Metadata changes on update; downloads/revenue buckets are monthly |
| iTunes Lookup `/lookup` | **86400** (1d) | Release notes change only on new version shipping |
| `apps.apple.com` scrape (reviews) | **21600** (6h) | Recent reviews stream in — 6h keeps signal warm |
| ASC `/v1/apps` | **86400** (1d) | App list rarely changes |
| ASC `/v1/salesReports` daily | **43200** (12h) | Daily reports settle within hours but don't change once stable |
| ASC `/v1/financeReports` monthly | **2592000** (30d) | Monthly reports are final after ~5 weeks |
| ASC `/v1/apps/{id}/customerReviews` | **3600** (1h) | Balance freshness with review traffic |
| Astro MCP | **not cached via this helper** — the MCP has its own data freshness and local DB |

Combine helpers:

```bash
JWT=$(tools/asc-jwt.sh)
tools/cached-curl.sh 43200 \
  "https://api.appstoreconnect.apple.com/v1/salesReports?filter[frequency]=DAILY&filter[reportType]=SALES&filter[reportSubType]=SUMMARY&filter[vendorNumber]=$ASC_VENDOR_NUMBER&filter[reportDate]=2026-04-15" \
  -H "Authorization: Bearer $JWT" -H "Accept: application/a-gzip"
```

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
| In-app purchase list | `monetization-strategy`, `subscription-lifecycle` — IAP flag is available via iTunes Lookup, full catalog via ASC API `GET /v1/inAppPurchasesV2` on the **own app** only |
| Review sentiment analysis (pre-computed) | `review-management`, `retention-optimization` — compute from scraped or ASC reviews in-skill |

**Covered via the official ASC API** (own app only, requires setup — see [tools/integrations/app-store-connect.md](integrations/app-store-connect.md) and the root README):

- Exact downloads / units / revenue (Sales reports)
- Subscription counts + every state transition (Subscription + Subscription Event reports)
- Actual net proceeds per region (Finance reports)
- App Store Connect Analytics (D1 / D7 / D28 retention, sessions, crashes, conversion rate, impressions)
- Complete review history with filters (`customerReviews`) + programmatic responses
- Product Page Optimization experiments + Custom Product Pages

## Skill → Tool Mapping

| Skill | Tools Used |
|-------|-----------|
| `aso-audit` | Astro `search_rankings`, `get_app_keywords`, `get_app_ratings` · Sensor Tower (metadata) · iTunes Lookup (What's New) |
| `keyword-research` | Astro `get_keyword_suggestions`, `search_rankings`, `add_keywords`, `extract_competitors_keywords` |
| `metadata-optimization` | Sensor Tower (metadata) · iTunes Lookup · Astro `get_app_keywords` |
| `competitor-analysis` | Astro `extract_competitors_keywords`, `search_rankings` · Sensor Tower (competitor batch: metadata, screenshots, downloads/revenue) |
| `screenshot-optimization` | Sensor Tower (screenshots + competitor screenshots) |
| `review-management` | App Store reviews (scrape) · Astro `get_app_ratings` (history) · **ASC API** `/v1/apps/{id}/customerReviews` (own app, authoritative) |
| `localization` | Astro `get_keyword_suggestions`, `search_rankings` (per store) · Sensor Tower (per-country metadata) |
| `app-launch` | Astro `search_app_store`, `get_keyword_suggestions` |
| `ua-campaign` | Astro `search_rankings`, `get_keyword_suggestions` · Sensor Tower (revenue/downloads benchmarks) · **ASC API** Sales reports (CAC × LTV math with real revenue) |
| `apple-search-ads` | Astro `search_rankings`, `get_keyword_suggestions`, `add_keywords` |
| `app-store-featured` | Sensor Tower (metadata) — market/featured data **not covered** (degraded) |
| `retention-optimization` | App Store reviews (scrape) · Sensor Tower (downloads trend) · **ASC API** analytics reports (D1/D7/D28 retention) |
| `monetization-strategy` | Sensor Tower (competitor revenue/downloads) · App Store reviews (scrape) · iTunes Lookup (IAP flag) · **ASC API** Sales + Finance reports (own-app revenue truth) |
| `app-analytics` | Sensor Tower (downloads/revenue) · Astro `search_rankings` · **ASC API** analytics + sales + finance reports |
| `ab-test-store-listing` | Sensor Tower (screenshots, metadata) · Astro `get_app_ratings` · **ASC API** PPO experiments + Custom Product Pages |
| `app-marketing-context` | Sensor Tower (metadata) · Astro `get_app_keywords`, `search_app_store` |
| `market-movers` | **Not covered** — relies on general knowledge + Astro `search_app_store` |
| `market-pulse` | **Not covered** — relies on general knowledge + Astro `search_app_store` |
| `asc-metrics` | **ASC API** (primary) — Sales, Subscription, Subscription Event, Finance reports |
| `seasonal-aso` | Astro `get_keyword_suggestions`, `search_rankings` |
| `in-app-events` | Astro `get_keyword_suggestions`, `search_rankings` · Sensor Tower (metadata) |
| `onboarding-optimization` | App Store reviews (scrape) · Sensor Tower (downloads) · **ASC API** analytics reports (D1 retention, sessions/device) + `customerReviews` for friction mining |
| `rating-prompt-strategy` | Astro `get_app_ratings` (history) · App Store reviews (scrape) · **ASC API** `/v1/apps/{id}/customerReviews` (version-correlated drops) |
| `app-icon-optimization` | Sensor Tower (icon + competitor icons) |
| `subscription-lifecycle` | Sensor Tower (competitor revenue) · App Store reviews (scrape) · **ASC API** Subscription + Subscription Event + Finance reports |
| `app-clips` | Astro `search_rankings` · Sensor Tower (metadata) |
| `competitor-tracking` | Astro `search_rankings`, `get_app_keywords`, `get_app_ratings` · Sensor Tower (metadata, downloads, revenue) · App Store reviews (scrape) |
| `crash-analytics` | App Store reviews (scrape) · Astro `get_app_ratings` |
| `press-and-pr` | Sensor Tower (metadata) · Astro `search_app_store` |

## Other Useful Tools

| Tool | Purpose | Integration |
|------|---------|-------------|
| **App Store Connect** | Official Apple analytics, releases, IAP management, first-party sales data | [app-store-connect.md](integrations/app-store-connect.md) |
| **RevenueCat** | Subscription analytics, paywall A/B testing | [revenuecat.md](integrations/revenuecat.md) |
| **Firebase** | In-app analytics, crash reporting, A/B testing | [firebase.md](integrations/firebase.md) |
