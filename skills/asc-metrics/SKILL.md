---
name: asc-metrics
description: When the user wants to analyze their own app's actual performance data from App Store Connect — real downloads, revenue, IAP, subscriptions, trials, or country breakdowns pulled directly from the official App Store Connect API. Use when the user asks about "my downloads", "my revenue", "how is my app performing", "ASC data", "sales and trends", "my subscription numbers", "App Store Connect metrics", or wants to compare periods or top markets. For third-party app estimates, see app-analytics. For subscription analytics depth, see monetization-strategy.
metadata:
  version: 1.0.0
---

# ASC Metrics

You analyze the user's **official App Store Connect data** pulled directly from Apple's App Store Connect API — exact downloads, revenue, IAP, subscriptions, and trials. This is first-party data, not estimates.

## Prerequisites

- App Store Connect API key with the **Sales and Finance** role (see [tools/integrations/app-store-connect.md](../../tools/integrations/app-store-connect.md))
- JWT built from the `.p8` key, Issuer ID, and Key ID
- Sales reports retention: rolling 365 days (daily), longer (weekly/monthly/yearly)

If the user hasn't generated an API key yet, point them to App Store Connect → Users and Access → Integrations → App Store Connect API and return.

## Initial Assessment

1. Check for `app-marketing-context.md` — read it for app context
2. Ask: **What do you want to analyze?** (downloads, revenue, subscriptions, country breakdown, trend comparison)
3. Ask: **Which time period?** (default: last 30 days)
4. Ask: **Specific app or all apps?**

## Fetching Data

All endpoints below live under `https://api.appstoreconnect.apple.com/v1/` and require a JWT in `Authorization: Bearer <jwt>`.

### Step 1 — List your apps

```bash
GET /v1/apps
```

Match the user's app to its `id` and `attributes.bundleId`.

### Step 2 — Pull Sales & Trends (portfolio or app)

```bash
GET /v1/salesReports
  ?filter[frequency]=DAILY
  &filter[reportType]=SALES
  &filter[reportSubType]=SUMMARY
  &filter[vendorNumber]=<your vendor id>
  &filter[reportDate]=YYYY-MM-DD
```

Returns a gzipped TSV. Parse and aggregate per-date / per-country / per-sku.

### Step 3 — Pull Subscription reports

```bash
GET /v1/salesReports
  ?filter[frequency]=DAILY
  &filter[reportType]=SUBSCRIPTION
  &filter[reportSubType]=SUMMARY
  &filter[vendorNumber]=<your vendor id>
  &filter[version]=1_4
  &filter[reportDate]=YYYY-MM-DD
```

### Step 4 — Pull Finance reports (actual paid revenue, monthly)

```bash
GET /v1/financeReports
  ?filter[regionCode]=Z1
  &filter[reportType]=FINANCIAL
  &filter[vendorNumber]=<your vendor id>
  &filter[reportDate]=YYYY-MM
```

Build your own `daily[]`, `countries[]`, and `totals` from the parsed TSVs.

See full integration guide: [app-store-connect.md](../../tools/integrations/app-store-connect.md)

## Analysis Frameworks

### Period-over-Period Comparison

Fetch two equal-length windows and compare:

| Metric | Prior Period | Current Period | Change |
|--------|-------------|----------------|--------|
| Downloads | [N] | [N] | [+/-X%] |
| Revenue | $[N] | $[N] | [+/-X%] |
| Subscriptions | [N] | [N] | [+/-X%] |
| Trials | [N] | [N] | [+/-X%] |
| Trial → Sub Rate | [X]% | [X]% | [+/-X pp] |

**What to look for:**
- Downloads rising but revenue flat → pricing or paywall issue
- Trials rising but conversions flat → paywall or onboarding issue
- Revenue rising but downloads flat → good monetization improvement

### Daily Trend Analysis

From `daily[]`, identify:
- **Spikes** — Did a feature, update, or press trigger them?
- **Drops** — Correlate with app updates, seasonality, or algorithm changes
- **Trend direction** — 7-day moving average vs prior 7 days

### Country Breakdown

Sort `countries[]` by downloads and revenue:
1. **Top 5 by downloads** — Are you investing in ASO for these markets?
2. **Top 5 by revenue** — Higher ARPD (avg revenue per download) = prioritize ASO
3. **High downloads, low revenue** — Markets with weak monetization
4. **Low downloads, high revenue** — Under-tapped premium markets (localize)

### Revenue Quality Check

Compute from the data:

| Metric | Formula | Benchmark |
|--------|---------|-----------|
| ARPD | Revenue / Downloads | > $0.05 good; > $0.20 excellent |
| Trial rate | Trials / Downloads | > 20% means strong paywall reach |
| Sub conversion | Subscriptions / Trials | > 25% is strong |
| Revenue per sub | Revenue / Subscriptions | Depends on pricing |

## Output Format

### Performance Snapshot

```
📊 [App Name] — [Period]

Downloads:     [N]  ([+/-X%] vs prior period)
Revenue:       $[N] ([+/-X%])
Subscriptions: [N]  ([+/-X%])
Trials:        [N]  ([+/-X%])
IAP Count:     [N]  ([+/-X%])
Trial→Sub:     [X]%

Top Markets (downloads):
  1. [Country] — [N] downloads, $[N]
  2. [Country] — [N] downloads, $[N]
  3. [Country] — [N] downloads, $[N]

Key Observations:
- [What the trend means]
- [Any anomaly and likely cause]
- [Opportunity identified]

Recommended Actions:
1. [Specific action based on data]
2. [Specific action based on data]
```

### Trend Alert

When a significant change (>20%) is detected, flag it:

```
⚠️  Downloads dropped [X]% this week
    Possible causes: [list 2-3 hypotheses]
    Next steps: [specific diagnostic actions]
```

## Common Questions

**"Why did my downloads drop?"**
1. Pull daily trend — when did it start?
2. Check if an update shipped on that date
3. Check keyword rankings (use `keyword-research` skill)
4. Check competitor activity (use `competitor-analysis` skill)

**"Which countries should I localize for?"**
Pull country breakdown → sort by downloads → flag high-download, non-English markets → use `localization` skill

**"Is my monetization improving?"**
Compare trial rate and trial→sub rate period over period → use `monetization-strategy` skill for paywall improvements

## Related Skills

- `app-analytics` — Full analytics stack setup and KPI framework
- `monetization-strategy` — Improve subscription conversion and paywall
- `retention-optimization` — Reduce churn using the metrics as input
- `localization` — Expand top-performing markets seen in country data
- `ua-campaign` — Validate whether paid installs show in downloads spike
