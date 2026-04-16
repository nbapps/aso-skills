# ASO & App Marketing Skills


<img width="1536" height="1024" alt="image" src="hero.png" />
<div align="center">
<p align="center">
  <a href="https://www.linkedin.com/in/erencanarica/">
    <img src="https://img.shields.io/badge/Follow on LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="Follow on LinkedIn" />
  </a>
  </p>
</div>

AI agent skills for App Store Optimization (ASO) and mobile app marketing. Built for indie developers, app marketers, and growth teams who want **Cursor**, **Claude Code**, or any [Agent Skills](https://agentskills.io)-compatible AI assistant to help with keyword research, metadata optimization, competitor analysis, and app growth.

Powered by real App Store data via a small, composable stack: the **[Astro](https://tryastro.app?aff=z0Jlp)** MCP (keywords, rankings, ratings), **Sensor Tower**'s public endpoint (metadata, screenshots, downloads / revenue estimates), **iTunes Lookup** (release notes), and a **web scrape of `apps.apple.com`** for user reviews.

> **Credits** — This repo is a fork and adaptation of [eronred/aso-skills](https://github.com/eronred/aso-skills) by [Erencan Arıca](https://www.linkedin.com/in/erencanarica/). The original skills were built on top of the Appeeky API; this fork swaps the data layer to the Astro MCP plus a few free public endpoints (Sensor Tower public, iTunes Lookup, `apps.apple.com` scrape), and reworks the skills that depended on Appeeky-only capabilities. All the ASO frameworks, scoring rubrics, and skill structure come from Erencan's original work — huge credit to him.

## Why This Exists

Most ASO knowledge lives in blog posts, courses, and expensive consultants. We packaged it into skills that any AI agent can use — so you get expert-level ASO guidance directly in your IDE.

Each skill contains battle-tested frameworks, scoring rubrics, and output templates. The agent reads the skill, pulls real data from the App Store (via the Astro MCP, Sensor Tower's public endpoint, iTunes Lookup, and a scrape of `apps.apple.com`) and gives you actionable recommendations — not generic advice.

## Quick Start

### 1. Install Astro

[**Download Astro**](https://tryastro.app?aff=z0Jlp) — macOS app that tracks your App Store keywords, rankings, and ratings, and exposes an MCP server for AI agents to consume that data.

Once installed, open Astro → **Settings** → enable the **MCP server**. It listens locally on `http://127.0.0.1:8089/mcp` (no auth, localhost-only).

### 2. Wire the MCP server into your agent

**Claude Code:**
```bash
claude mcp add --transport http astro http://127.0.0.1:8089/mcp
```

**Cursor** — edit `~/.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "astro": {
      "url": "http://127.0.0.1:8089/mcp"
    }
  }
}
```

**VS Code** — edit `~/.vscode/mcp.json` or `.vscode/mcp.json`:
```json
{
  "servers": {
    "astro": {
      "type": "http",
      "url": "http://127.0.0.1:8089/mcp"
    }
  }
}
```

### 3. Install the skills

**Cursor** — Settings (Cmd+Shift+J) → Rules → Add Rule → Remote Rule (Github) → paste `https://github.com/nbapps/aso-skills`

**Claude Code** — `npx skills add nbapps/aso-skills`

**Manual** — `git clone https://github.com/nbapps/aso-skills.git && cp -r aso-skills/skills/* .cursor/skills/`

Then ask your agent:

```
"Run an ASO audit for my app (id: 1617391485)"
"Find the best keywords for a meditation app"
"Optimize my App Store title and subtitle"
"Set up a weekly competitor monitoring routine for apps X, Y, Z"
"My app rating dropped — how do I recover it?"
"Build an Apple Search Ads campaign structure for my fitness app"
"Help me plan a Christmas In-App Event"
"What seasonal keywords should I add in December?"
"Optimize my Google Play listing"
"Help me pitch TechCrunch for my app launch"
"My app has a crash affecting 2% of sessions — help me triage it"
```

Or invoke directly: `/aso-audit`, `/keyword-research`, `/metadata-optimization`, `/asc-metrics`, `/in-app-events`, `/seasonal-aso`, `/apple-search-ads`, `/competitor-tracking`

## Skills

### ASO Core

| Skill | What it does |
|-------|-------------|
| [`aso-audit`](skills/aso-audit) | Scores your listing across 10 factors (0-100), flags problems, gives a prioritized fix list |
| [`keyword-research`](skills/keyword-research) | Finds keywords by volume × difficulty × relevance, groups them into primary/secondary/long-tail |
| [`metadata-optimization`](skills/metadata-optimization) | Writes title, subtitle, keyword field, description — with 3 variants and character counts |
| [`competitor-analysis`](skills/competitor-analysis) | Keyword gaps, creative teardown, positioning map, and specific opportunities to exploit |
| [`seasonal-aso`](skills/seasonal-aso) | Seasonal keyword calendar, metadata swap strategy, timing checklist, and trending-moment tactics |

### Creative & International

| Skill | What it does |
|-------|-------------|
| [`screenshot-optimization`](skills/screenshot-optimization) | 10-slot screenshot strategy with design briefs, text overlay copy, and competitor audit |
| [`app-icon-optimization`](skills/app-icon-optimization) | Icon design principles, A/B testing via PPO/Play Experiments, category differentiation, and icon briefs |
| [`review-management`](skills/review-management) | Sentiment analysis, response templates (HEAR framework), rating improvement tactics |
| [`localization`](skills/localization) | Market prioritization matrix, per-country keyword research, cultural adaptation checklist |

### Growth

| Skill | What it does |
|-------|-------------|
| [`app-launch`](skills/app-launch) | 8-week launch timeline with daily checklists, channel strategy, and press outreach templates |
| [`ua-campaign`](skills/ua-campaign) | Apple Search Ads, Meta, Google UAC — campaign structure, bidding, creative specs, budget allocation |
| [`apple-search-ads`](skills/apple-search-ads) | Deep-dive ASA — campaign structure, match types, CPP routing, bid strategy, weekly optimization checklist |
| [`app-store-featured`](skills/app-store-featured) | Featuring readiness score, Apple tech checklist, pitch template, In-App Events calendar |
| [`in-app-events`](skills/in-app-events) | Plan and write App Store In-App Events — copy, image brief, keyword strategy, submission timeline |
| [`app-clips`](skills/app-clips) | App Clip use cases, card design, URL scheme setup, SKOverlay handoff, and measurement |
| [`press-and-pr`](skills/press-and-pr) | Media targeting tiers, pitch templates, press kit checklist, embargo strategy, Product Hunt launch |

### Revenue & Retention

| Skill | What it does |
|-------|-------------|
| [`monetization-strategy`](skills/monetization-strategy) | Pricing tiers, paywall timing/design, trial optimization, category benchmarks |
| [`subscription-lifecycle`](skills/subscription-lifecycle) | Trial nurture sequences, voluntary/involuntary churn reduction, dunning, and win-back campaigns |
| [`retention-optimization`](skills/retention-optimization) | Activation → habit → engagement framework, push notification sequences, churn prevention |
| [`onboarding-optimization`](skills/onboarding-optimization) | First-run flow audit, activation event definition, permission prompt timing, sign-up friction reduction |
| [`rating-prompt-strategy`](skills/rating-prompt-strategy) | SKStoreReviewRequest / Play In-App Review timing, pre-prompt survey, version-gating, and rating recovery |

### Analytics & Testing

| Skill | What it does |
|-------|-------------|
| [`app-analytics`](skills/app-analytics) | Event tracking plan, dashboard setup, KPI framework with category benchmarks |
| [`ab-test-store-listing`](skills/ab-test-store-listing) | Hypothesis → variant design → sample size → interpretation for App Store A/B tests |
| [`asc-metrics`](skills/asc-metrics) | Analyze your exact App Store Connect data (downloads, revenue, subscriptions, countries) via the official ASC API |
| [`crash-analytics`](skills/crash-analytics) | Crashlytics setup, crash triage framework (P0–P3), symbolication, phased release strategy, rating recovery |

### Market Intelligence *(degraded)*

These skills still load and run, but have no live data source in the current stack — they degrade to general-knowledge output. See [tools/REGISTRY.md](tools/REGISTRY.md).

| Skill | What it does |
|-------|-------------|
| [`market-movers`](skills/market-movers) | Top chart gainers/losers, new entries, and dropped apps |
| [`market-pulse`](skills/market-pulse) | Full market briefing: chart movements + trending keywords + featured apps + new launches |
| [`competitor-tracking`](skills/competitor-tracking) | Weekly competitor surveillance — metadata changes, keyword shifts, rating trends (live, non-degraded) |

### Foundation

| Skill | What it does |
|-------|-------------|
| [`app-marketing-context`](skills/app-marketing-context) | Creates a context doc (app, audience, competitors, goals) that all other skills reference |

## How It Works

```
You: "Run an ASO audit for Headspace"

Agent:
  1. Reads aso-audit/SKILL.md (framework, scoring rubric, output template)
  2. Pulls metadata from Sensor Tower, release notes from iTunes Lookup,
     keywords + ratings from the Astro MCP, reviews from the apps.apple.com scrape
  3. Scores each factor (title: 8/10, subtitle: 6/10, keywords: 4/10...)
  4. Returns: ASO Score Card + Quick Wins + High-Impact Changes + Strategic Recs
```

Skills reference each other — `aso-audit` might suggest running `keyword-research` for deeper analysis, which then feeds into `metadata-optimization` for implementation.

## Installation Reference

### Cursor

| Method | Command |
|--------|---------|
| GitHub Import | Settings → Rules → Add Rule → Remote Rule → `https://github.com/nbapps/aso-skills` |
| Project-level | `cp -r aso-skills/skills/* .cursor/skills/` |
| Global | `cp -r aso-skills/skills/* ~/.cursor/skills/` |

### Claude Code

| Method | Command |
|--------|---------|
| CLI | `npx skills add nbapps/aso-skills` |
| Specific skills | `npx skills add nbapps/aso-skills --skill aso-audit keyword-research` |
| Manual | `cp -r aso-skills/skills/* .claude/skills/` |

### Any Agent

```bash
git submodule add https://github.com/nbapps/aso-skills.git .agents/aso-skills
```

Works with any tool that supports the [Agent Skills](https://agentskills.io) standard (`.agents/skills/`, `.cursor/skills/`, `.claude/skills/`, `.codex/skills/`).

## Data Stack

Skills work standalone with general ASO knowledge. For real-time data they compose four sources:

| Source | Role | Auth |
|--------|------|------|
| **[Astro MCP](tools/integrations/astro.md)** | Keyword tracking, rankings (+ history + volatility + trend), ratings (+ history), App Store search, AI keyword suggestions, competitor keyword extraction | None (localhost-only) |
| **[Sensor Tower public](tools/integrations/sensor-tower.md)** | App metadata (title, subtitle, description, promo text, categories, languages), screenshots, icon, monthly downloads & revenue estimates | None |
| **[iTunes Lookup](tools/integrations/itunes-lookup.md)** | Release notes / What's New, per-country metadata, supported languages, file size, minimum OS | None |
| **[App Store reviews scrape](tools/integrations/apple-reviews-scrape.md)** | ~40 SSR-rendered reviews per country per request (Apple's public RSS feed is effectively deprecated) | None |

### First-Party ASC Data — `asc-metrics`

The `asc-metrics` skill pulls directly from the **official [App Store Connect API](tools/integrations/app-store-connect.md)** — exact downloads, revenue, subscriptions, trials, and country breakdowns from Sales & Finance reports.

```
"How are my downloads trending this month?"
"What are my top 5 markets by revenue?"
"Compare this month's subscriptions to last month"
```

#### Setup

**1. Create an API key in App Store Connect**

Go to [App Store Connect](https://appstoreconnect.apple.com/access/integrations/api) → **Users and Access** → **Integrations** → **App Store Connect API** → click **+**.

- **Name:** any (e.g. `ASO Skills`)
- **Role:** **Admin** (recommended — one key covers Sales, Finance, reviews, versions). A key can hold only one role, so if you want strict separation, create two keys: one `Sales` (for `/v1/salesReports`) and one `Finance` (for `/v1/financeReports`).
- Click **Generate**, then **Download API Key** — the `.p8` file is only downloadable **once**. Store it safely. If lost, the key must be revoked and regenerated.

**2. Gather the three IDs**

| ID | Where to find it |
|----|------------------|
| **Key ID** (10 chars) | Shown on the same page, next to the key you just created (e.g. `K83TLBA447`) |
| **Issuer ID** (UUID) | Top of the **App Store Connect API** page (e.g. `57246542-96fe-1a63-e053-0824d011072a`) |
| **Vendor Number** (8 digits) | [Payments and Financial Reports](https://appstoreconnect.apple.com/itc/payments_and_financial_reports) → top of page (e.g. `Vendor # 80123456`) |

**3. Drop the files in `~/.config/aso/`**

> **Do not rename the `.p8` file.** Skills derive the key path from the `ASC_KEY_ID` env var using the convention `~/.config/aso/AuthKey_${ASC_KEY_ID}.p8` — the Apple-assigned filename must be preserved.

```bash
mkdir -p ~/.config/aso

# Move the downloaded .p8 without renaming it
mv ~/Downloads/AuthKey_<KEY_ID>.p8 ~/.config/aso/

# Create config.env
cat > ~/.config/aso/config.env <<'EOF'
ASC_KEY_ID=<10-char Key ID>
ASC_ISSUER_ID=<UUID>
ASC_VENDOR_NUMBER=<8-digit number>
EOF

# Lock down permissions — the .p8 is a private key
chmod 700 ~/.config/aso
chmod 600 ~/.config/aso/config.env ~/.config/aso/AuthKey_*.p8
```

**4. Verify**

```bash
source ~/.config/aso/config.env
echo "Key: $ASC_KEY_ID · Issuer: $ASC_ISSUER_ID · Vendor: $ASC_VENDOR_NUMBER"
ls -l ~/.config/aso/AuthKey_${ASC_KEY_ID}.p8
```

Both files should be listed with `-rw-------` perms.

### Helpers & Caching

Two zero-dep shell scripts in `tools/` keep the wiring between skills and external data clean:

| Helper | What it does |
|--------|--------------|
| [`tools/asc-jwt.sh`](tools/asc-jwt.sh) | Reads `~/.config/aso/config.env` + the `.p8` key, emits an ES256 JWT (20-min expiry, audience `appstoreconnect-v1`) on stdout. Dependencies: `bash`, `openssl`, `python3` stdlib — no `pip install`. |
| [`tools/cached-curl.sh`](tools/cached-curl.sh) | `curl` wrapper that caches GET responses at `~/.cache/aso/<sha1>.body` with a configurable TTL. Keeps rate-limit pressure off Sensor Tower, iTunes Lookup, the `apps.apple.com` scrape, and the ASC API. |

Combined pattern:

```bash
JWT=$(tools/asc-jwt.sh)

# 12h cache for daily Sales reports
tools/cached-curl.sh 43200 \
  "https://api.appstoreconnect.apple.com/v1/salesReports?filter[frequency]=DAILY&filter[reportType]=SALES&filter[reportSubType]=SUMMARY&filter[vendorNumber]=$ASC_VENDOR_NUMBER&filter[reportDate]=2026-04-15" \
  -H "Authorization: Bearer $JWT" -H "Accept: application/a-gzip"
```

For reports that return empty until Apple settles them (e.g. Finance reports, which take ~5 weeks after month-end), layer a short fallback TTL on top of the main TTL — the cache re-fetches the empty response after the short window, but holds the populated one for the full duration:

```bash
# 30d when populated, 24h when empty
ASO_CACHE_EMPTY_TTL=86400 tools/cached-curl.sh 2592000 \
  "https://api.appstoreconnect.apple.com/v1/financeReports?filter[regionCode]=Z1&filter[reportType]=FINANCIAL&filter[vendorNumber]=$ASC_VENDOR_NUMBER&filter[reportDate]=2026-03" \
  -H "Authorization: Bearer $JWT"
```

Recommended TTLs per source (full table in [tools/REGISTRY.md](tools/REGISTRY.md#helpers)):

| Source | Main TTL | Empty TTL |
|--------|----------|-----------|
| Sensor Tower `/api/ios/apps` | 24h | — |
| iTunes Lookup `/lookup` | 24h | — |
| `apps.apple.com` scrape (reviews) | 6h | — |
| ASC `/v1/apps` | 24h | — |
| ASC `/v1/salesReports` daily | 12h | 24h (for days with no activity) |
| ASC `/v1/financeReports` monthly | 30d | 24h (for months not yet settled) |
| ASC `/v1/apps/{id}/customerReviews` | 1h | — |
| Astro MCP | not cached (MCP has its own freshness) | — |

### Not Covered

Market-wide intelligence (chart rankings by country, market movers, trending keywords, featured apps, new releases) is **not covered** by the current stack. Affected skills (`market-movers`, `market-pulse`, `app-store-featured`) degrade to general-knowledge output. See [tools/REGISTRY.md](tools/REGISTRY.md) for the full capability matrix.

## Contributing

PRs welcome — fix an inaccuracy, improve a framework, or add a new skill. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
