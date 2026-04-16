---
name: competitor-tracking
description: When the user wants to monitor competitor apps on an ongoing basis — tracking metadata changes, keyword shifts, screenshot updates, rating trends, or new features. Use when the user mentions "competitor monitoring", "track competitors", "competitor alert", "competitor changed their title", "watch a competitor app", "competitor weekly report", "competitive intelligence", or "what changed in competitor's listing". For a one-time deep competitive analysis, see competitor-analysis. For market-wide chart movements, see market-movers.
metadata:
  version: 1.0.0
---

# Competitor Tracking

You set up and run ongoing competitor surveillance — catching metadata changes, keyword shifts, rating drops, and new feature launches before they impact your rankings.

## One-Time Analysis vs Ongoing Tracking

| | `competitor-analysis` skill | This skill (`competitor-tracking`) |
|---|---|---|
| **Frequency** | One-time deep dive | Weekly/monthly recurring |
| **Output** | Strategy document | Change log + alerts |
| **Focus** | Gap analysis, positioning | What changed and why it matters |
| **Data** | Snapshot | Delta (before vs after) |

## Setup: Define Your Watchlist

1. Check for `app-marketing-context.md`
2. Ask: **Who are your top 3–5 competitors?** (get App IDs if possible)
3. Ask: **How often do you want to review?** (weekly recommended)
4. Ask: **What are you most concerned about?** (keywords, ratings, creative, pricing)

Use the Astro MCP to identify competitors on a target keyword:
```
astro.search_app_store(keyword: "meditation", store: "us", limit: 10)
astro.extract_competitors_keywords(keyword: "meditation", store: "us")  # only if keyword is tracked
```

## What to Track

### Metadata Changes

Check weekly with Sensor Tower (batch) + iTunes Lookup for release notes:
```bash
# Metadata + screenshots + downloads/revenue for all competitors in one call
curl "https://app.sensortower.com/api/ios/apps?app_ids=ID1,ID2,ID3"

# Release notes / What's New (per competitor)
curl "https://itunes.apple.com/lookup?id=ID1&country=us"
```

Watch for:
- **Title / subtitle / description changes** — new keyword targeting, repositioning
- **Screenshot updates** — new creative direction or A/B test winner shipped
- **Release notes** — signals what they shipped
- **Downloads / revenue delta** — momentum vs last check

### Keyword Ranking Changes

```
astro.get_app_keywords(appId: "ID1", store: "us")             # competitor's tracked keywords
astro.search_rankings(keyword: "<shared>", store: "us",       # who ranks where on a shared keyword
                       includeHistory: true, period: "month")
```

Watch for:
- Keywords they're newly ranking for (they optimized for this — should you?)
- Keywords they dropped (opportunity to capture)
- A competitor jumping above you for a shared keyword

### Ratings and Reviews

```
astro.get_app_ratings(appId: "ID1", store: "us", includeHistory: true)
```

Pair with scraped App Store reviews for the qualitative story:
```bash
curl -sL -A "Mozilla/5.0" "https://apps.apple.com/us/app/_/idID1" -o /tmp/app.html
# Extract the <script type="application/json"> block and walk for $kind == "Review"
# See tools/integrations/apple-reviews-scrape.md for the Python extractor
```

Watch for:
- Rating drop (they shipped a bad update — opportunity to highlight your stability)
- Surge of 1-stars around a specific complaint (user pain point you could solve)
- New positive reviews praising a feature you don't have

### Chart Positions

> Category charts and market movers are **not covered** by the current stack — infer momentum from Sensor Tower downloads/revenue deltas and Astro rankings on category-defining keywords.

### Pricing and Paywall

Manually check every 4–6 weeks:
- Trial length changes
- Price changes (lower = aggressive growth; higher = LTV optimization)
- New paywall format or plans

## Weekly Competitive Report Template

Run this analysis every Monday:

```
Competitive Update — Week of [Date]

Apps tracked: [list names]

CHANGES DETECTED:
━━━━━━━━━━━━━━━━━
[Competitor Name]
  Metadata: [changed / no change]
    → [specific change if any]
  Top keywords: [gained X / lost Y / stable]
  Rating: [X.X → X.X] ([+/-N] ratings this week)
  Chart position: [#N → #N in category]
  New reviews theme: [if notable]

[Repeat per competitor]

OPPORTUNITIES IDENTIFIED:
1. [Competitor X dropped keyword Y — consider targeting it]
2. [Competitor X has surge of complaints about Z — your strength]
3. [Competitor X raised price — positioning opportunity]

THREATS:
1. [Competitor X now ranks #3 for [keyword] — we're at #8]
2. [New entrant spotted: [name] — check their metadata]

ACTION ITEMS:
1. [Specific response to a change]
2. [Keyword to target based on competitor gap]
```

## Monthly Deep-Dive Triggers

Run a full `competitor-analysis` when:
- A competitor jumps 10+ positions in the category chart
- A competitor changes their title (signals major repositioning)
- A new competitor enters the top 10 in your category
- Your ranking drops on a keyword a competitor recently targeted

## Automation Options

### Manual (recommended for small teams)

Set a calendar reminder. Run the Astro MCP calls + Sensor Tower / iTunes Lookup / RSS fetches above. Fill the template.

### Semi-automated

Build a script that pulls the baseline weekly and diffs results:

```bash
#!/bin/bash
APPS="6759740679,987654321,111222333"

# One call returns metadata + screenshots + downloads/revenue for all competitors
curl -s "https://app.sensortower.com/api/ios/apps?app_ids=$APPS" \
  | jq '.[] | {app_id, name, version, humanized_worldwide_last_month_downloads, humanized_worldwide_last_month_revenue, current_version_rating, current_version_rating_count}'

# Release notes per competitor
for APP_ID in ${APPS//,/ }; do
  curl -s "https://itunes.apple.com/lookup?id=$APP_ID&country=us" \
    | jq '.results[] | {trackId, version, currentVersionReleaseDate, releaseNotes}'
done
```

Store results weekly and diff with the previous week's output.

### Agent-driven (Claude / Cursor)

Ask your agent each Monday:
```
"Run a competitor check on apps [ID1], [ID2], [ID3] and
compare their metadata, top keywords, ratings, and downloads/revenue to last week."
```

The agent will combine Astro (`get_app_keywords`, `search_rankings`, `get_app_ratings`), Sensor Tower (metadata + estimates), iTunes Lookup (release notes) and scraped App Store reviews to produce the report.

## Competitive Response Playbook

| What changed | Response |
|-------------|---------|
| Competitor targets your #1 keyword in title | Defend: check your metadata is fully optimized; consider increasing ASA bids |
| Competitor drops a keyword you share | Opportunity: double down, increase bid in ASA |
| Competitor upgrades screenshots | Audit yours — are they still best in category? |
| Competitor rating drops below 4.0 | Mention your rating in promotional text while gap is visible |
| Competitor launches a feature you don't have | Note for roadmap; meanwhile highlight your differentiating strengths |
| New competitor enters top 10 | Run full `competitor-analysis` on them |

## Related Skills

- `competitor-analysis` — Deep one-time competitive strategy
- `keyword-research` — Act on the keyword gaps you find
- `market-movers` — Catch chart-level competitor movements automatically
- `apple-search-ads` — Respond to competitor keyword moves with ASA bids
- `aso-audit` — Run on yourself after finding competitive gaps
