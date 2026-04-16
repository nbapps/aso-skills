# App Store Connect

Apple's official portal for managing your app on the App Store.

**URL:** [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
**API Docs:** [developer.apple.com/app-store-connect/api](https://developer.apple.com/documentation/appstoreconnectapi)

## What It Provides

App Store Connect is the source of truth for your app's performance. It provides data that no third-party tool can access.

### Analytics (Free)

| Metric | Description | Skill Usage |
|--------|-------------|-------------|
| **Impressions** | Times your app appeared in search/browse | `aso-audit`, `ab-test-store-listing` |
| **Product Page Views** | Users who visited your product page | `screenshot-optimization`, `ab-test-store-listing` |
| **Conversion Rate** | Views → Downloads | `aso-audit`, `ab-test-store-listing` |
| **App Units** | First-time downloads | `app-analytics`, `ua-campaign` |
| **Proceeds** | Revenue after Apple's cut | `monetization-strategy`, `app-analytics` |
| **Sessions** | App opens | `retention-optimization`, `app-analytics` |
| **Active Devices** | Unique devices | `app-analytics` |
| **Retention** | Day 1, 7, 28 | `retention-optimization` |
| **Crash Rate** | Crashes per session | `app-analytics` |

### Source Types

Understand where your downloads come from:

| Source | Description |
|--------|-------------|
| App Store Search | User searched and found you |
| App Store Browse | User found you browsing charts/categories |
| App Referral | User came from another app |
| Web Referral | User came from a website link |

### Product Page Optimization (A/B Testing)

Built-in A/B testing for:
- App icon (up to 3 variants)
- Screenshots (up to 3 variants)
- App preview video (up to 3 variants)

See `ab-test-store-listing` skill for detailed guidance.

### Custom Product Pages

Create up to 35 custom product pages with unique:
- Screenshots
- App preview videos
- Promotional text

Each gets a unique URL for targeted campaigns.

## Key Actions for ASO

### Metadata Updates
- Update title, subtitle, keyword field with each version
- Update description and screenshots anytime
- Update promotional text without app review

### In-App Events
- Create events that appear on Today tab and search
- Schedule up to 10 events at a time
- Types: challenge, competition, live event, major update, premiere, special event

### App Review Responses
- Respond to user reviews directly
- Responses are public and visible to all users

## API Access

For automated workflows, use the App Store Connect API. All requests need a JWT built from a `.p8` key, your Issuer ID, and the Key ID.

### Setup

1. App Store Connect → Users and Access → Integrations → **App Store Connect API**
2. Generate a new key with the **Sales and Finance** role (needed for sales/finance reports) — download the `.p8` file (only once)
3. Note the **Issuer ID** and **Key ID**
4. Generate a JWT (ES256, 20-min expiry max). Many SDKs do this: [app-store-connect-jwt helpers](https://developer.apple.com/documentation/appstoreconnectapi/generating-tokens-for-api-requests)

### Core endpoints

```bash
# App list (find your id + bundleId)
curl -H "Authorization: Bearer $JWT" \
  "https://api.appstoreconnect.apple.com/v1/apps"

# Customer reviews (read)
curl -H "Authorization: Bearer $JWT" \
  "https://api.appstoreconnect.apple.com/v1/apps/$APP_ID/customerReviews"

# Review responses (reply)
POST /v1/customerReviewResponses

# Version management
GET /v1/apps/{id}/appStoreVersions

# Country availability
GET /v1/apps/{id}/appAvailabilities
```

### Sales & Trends (downloads, proceeds, IAP, subs — first-party)

Returns a gzipped TSV per report. Parse and aggregate in-skill.

```bash
# Daily sales summary
GET /v1/salesReports
  ?filter[frequency]=DAILY
  &filter[reportType]=SALES
  &filter[reportSubType]=SUMMARY
  &filter[vendorNumber]=<vendor id>
  &filter[reportDate]=YYYY-MM-DD

# Daily subscription summary
GET /v1/salesReports
  ?filter[frequency]=DAILY
  &filter[reportType]=SUBSCRIPTION
  &filter[reportSubType]=SUMMARY
  &filter[version]=1_4
  &filter[vendorNumber]=<vendor id>
  &filter[reportDate]=YYYY-MM-DD

# Subscription events (trials, conversions, cancellations)
GET /v1/salesReports
  ?filter[frequency]=DAILY
  &filter[reportType]=SUBSCRIPTION_EVENT
  &filter[reportSubType]=SUMMARY
  &filter[version]=1_3
  &filter[vendorNumber]=<vendor id>
  &filter[reportDate]=YYYY-MM-DD
```

### Finance Reports (actual paid proceeds per region, monthly)

```bash
GET /v1/financeReports
  ?filter[regionCode]=Z1
  &filter[reportType]=FINANCIAL
  &filter[vendorNumber]=<vendor id>
  &filter[reportDate]=YYYY-MM
```

`Z1` = all regions. Use a specific region code (e.g. `US`, `FR`, `JP`) for per-country finance data.

### Retention

- Daily Sales reports — rolling 365 days
- Weekly / Monthly / Yearly Sales reports — longer retention
- Finance reports — available ~5 weeks after month-end

## When to Use App Store Connect vs Third-Party

| Need | App Store Connect | Astro | Sensor Tower (public) |
|------|------------------|-------|-----------------------|
| Your app's exact download numbers | ✓ (official) | ✗ | Estimate only |
| Your app's exact revenue | ✓ (official) | ✗ | Estimate only |
| IAP counts, trials, subscriptions | ✓ (official) | ✗ | ✗ (flag only) |
| Country breakdown (exact) | ✓ | ✗ | ✗ |
| Competitor metadata + estimates | ✗ | Partial | ✓ |
| Keyword rankings | ✗ | ✓ | ✗ |
| Keyword volume/difficulty | ✗ | ✓ | ✗ |
| A/B test setup | ✓ (native) | ✗ | ✗ |
| Review management (respond) | ✓ | ✗ | ✗ |
| Review text (read) | ✓ | ✗ | ✗ (scrape `apps.apple.com`) |

For first-party sales/revenue/subscription analysis, see the `asc-metrics` skill — it parses the Sales & Finance reports above directly.
