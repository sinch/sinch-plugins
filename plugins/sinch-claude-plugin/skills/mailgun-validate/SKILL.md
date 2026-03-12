---
name: sinch-mailgun-validate
description: Build with Mailgun Validate API for email verification. Use when validating email addresses, checking list health, or running bulk validation jobs.
---

# Mailgun Validate

## Overview

Mailgun Validate (by Sinch) is an email verification and list hygiene service. It validates individual email addresses in real time and runs bulk validation jobs on entire lists. It also provides List Health Previews -- a free, risk-free sample assessment of a list's quality before committing to full validation.

## Getting Started

### Authentication

See the [sinch-authentication](../authentication/SKILL.md) skill for full auth setup, SDK initialization, and dashboard links.

All API requests use HTTP Basic Auth (same as Mailgun Send):
- **Username:** `api`
- **Password:** Your Mailgun Private API key

```bash
curl --user 'api:YOUR_API_KEY' \
  https://api.mailgun.net/v4/address/validate?address=test@example.com
```

### Base URLs (Regions)

Mailgun Validate operates in US and EU regions. Use the correct base URL for your account's region:

| Region | Endpoint              |
|--------|-----------------------|
| US     | api.mailgun.net       |
| EU     | api.eu.mailgun.net    |

### First API Call: Validate a Single Address

```bash
curl --user 'api:YOUR_API_KEY' \
  "https://api.mailgun.net/v4/address/validate?address=recipient@example.com"
```

Successful response:
```json
{
  "address": "recipient@example.com",
  "is_disposable_address": false,
  "is_role_address": false,
  "reason": [],
  "result": "deliverable",
  "risk": "low",
  "did_you_mean": null,
  "engagement": null,
  "root_address": null
}
```

## Key Concepts

### Single Address Validation

Real-time validation of individual email addresses. Returns a result classification, risk level, and flags for disposable or role-based addresses.

**Result classifications:**
- `deliverable` -- address exists and can receive email
- `undeliverable` -- address does not exist or cannot receive email
- `do_not_send` -- address is a known risk (spam trap, disposable, etc.)
- `catch_all` -- domain accepts all addresses; deliverability uncertain
- `unknown` -- validation could not determine status

**Risk levels:**
- `low` -- safe to send
- `medium` -- proceed with caution
- `high` -- avoid sending
- `unknown` -- risk could not be determined

**Flags:**
- `is_disposable_address` -- temporary/throwaway email service (e.g., Mailinator, Guerrilla Mail)
- `is_role_address` -- role-based address (e.g., info@, admin@, support@) rather than a personal mailbox

**Engagement data** (when available):
- `engagement.engaging` -- whether the address shows engagement signals
- `engagement.behavior` -- engagement behavior description
- `engagement.is_bot` -- whether the address shows bot-like behavior

**Additional fields:**
- `root_address` -- the root/canonical form of the address (if different from input)
- `last_seen` -- unix timestamp of when the address was last observed (when available)

### List Health Preview

A free, non-destructive sample assessment of a mailing list's quality. Analyzes a subset of addresses and returns deliverability ratios and risk breakdown -- useful for deciding whether to run a full (paid) bulk validation.

Preview results include:
- **Result breakdown** (deliverable / do_not_send / undeliverable / unknown) as percentages
- **Risk breakdown** (high / medium / low / unknown) as percentages
- **Quantity** of addresses in the list

### Bulk Validation

Full validation of an entire mailing list uploaded as a CSV or gzip file (max 25 MB). Returns per-address results with downloadable CSV and JSON output.

**Job lifecycle:**
1. Upload a CSV file to create a bulk validation job (returns 202)
2. Job moves through statuses: `created` → `processing` → `uploading` → `uploaded` (or `failed`)
3. Download results via the provided `download_url` (available when status is `uploaded`)

Maximum 5 parallel bulk validation jobs.

**Required header for bulk endpoints:** `X-Mailgun-Account-Id` must be included on GET, LIST, and DELETE bulk validation requests.

### Promoting a Preview to Full Validation

After reviewing a List Health Preview, you can promote it to a full bulk validation job without re-uploading the file.

## Common Patterns

### Validate a Single Address

```bash
curl --user 'api:YOUR_API_KEY' \
  "https://api.mailgun.net/v4/address/validate?address=jane@example.com"
```

Response:
```json
{
  "address": "jane@example.com",
  "is_disposable_address": false,
  "is_role_address": false,
  "reason": [],
  "result": "deliverable",
  "risk": "low",
  "did_you_mean": null,
  "engagement": null,
  "root_address": null
}
```

### Validate with Provider Lookup Disabled

Disable provider-level checks for faster validation (less accurate):

```bash
curl --user 'api:YOUR_API_KEY' \
  "https://api.mailgun.net/v4/address/validate?address=jane@example.com&provider_lookup=false"
```

### Create a List Health Preview

Upload a CSV file for a sampled preview assessment:

```bash
curl --user 'api:YOUR_API_KEY' \
  -X POST https://api.mailgun.net/v4/address/validate/preview/my-list-2026 \
  -F file=@/path/to/list.csv
```

Or start a preview for an existing mailing list by `list_id`:

```bash
curl --user 'api:YOUR_API_KEY' \
  -X POST https://api.mailgun.net/v4/address/validate/preview/my-existing-list
```

### Check Preview Status

```bash
curl --user 'api:YOUR_API_KEY' \
  https://api.mailgun.net/v4/address/validate/preview/my-list-2026
```

Response (when complete):
```json
{
  "id": "my-list-2026",
  "valid": true,
  "status": "preview_complete",
  "quantity": 10000,
  "created_at": 1739750400,
  "summary": {
    "result": {
      "deliverable": 75.2,
      "do_not_send": 2.1,
      "undeliverable": 18.7,
      "unknown": 4.0
    },
    "risk": {
      "high": 10.5,
      "low": 75.2,
      "medium": 10.3,
      "unknown": 4.0
    }
  }
}
```

Note: `created_at` is a unix timestamp (integer), not an ISO date string. Preview result percentages use underscored keys (`do_not_send`), unlike bulk validation summaries which use undelimited keys (`donotsend`).

### List All Previews

```bash
curl --user 'api:YOUR_API_KEY' \
  https://api.mailgun.net/v4/address/validate/preview
```

### Promote Preview to Full Bulk Validation

If the preview looks acceptable, promote to a full validation without re-uploading:

```bash
curl --user 'api:YOUR_API_KEY' \
  -X PUT https://api.mailgun.net/v4/address/validate/preview/my-list-2026
```

### Run a Full Bulk Validation

```bash
curl --user 'api:YOUR_API_KEY' \
  -X POST https://api.mailgun.net/v4/address/validate/bulk/campaign-q2-2026 \
  -F file=@/path/to/list.csv
```

### Check Bulk Validation Status

```bash
curl --user 'api:YOUR_API_KEY' \
  -H 'X-Mailgun-Account-Id: YOUR_ACCOUNT_ID' \
  https://api.mailgun.net/v4/address/validate/bulk/campaign-q2-2026
```

Response (when status is `uploaded`):
```json
{
  "id": "campaign-q2-2026",
  "status": "uploaded",
  "quantity": 50000,
  "records_processed": 48500,
  "created_at": 1708099200,
  "summary": {
    "result": {
      "deliverable": 38000,
      "donotsend": 1200,
      "undeliverable": 5100,
      "catchall": 3200,
      "unknown": 1000
    },
    "risk": {
      "high": 6300,
      "low": 38000,
      "medium": 3200,
      "unknown": 1000
    }
  },
  "download_url": {
    "csv": "https://...",
    "json": "https://..."
  }
}
```

### List All Bulk Validation Jobs

```bash
curl --user 'api:YOUR_API_KEY' \
  -H 'X-Mailgun-Account-Id: YOUR_ACCOUNT_ID' \
  https://api.mailgun.net/v4/address/validate/bulk
```

### Cancel or Delete a Bulk Validation Job

```bash
curl --user 'api:YOUR_API_KEY' \
  -H 'X-Mailgun-Account-Id: YOUR_ACCOUNT_ID' \
  -X DELETE https://api.mailgun.net/v4/address/validate/bulk/campaign-q2-2026
```

## Gotchas and Best Practices

1. **Preview before bulk validation** -- List Health Previews are free and non-destructive. Always run a preview first to assess list quality before committing to a paid bulk validation job.
2. **Result vs risk** -- `result` tells you whether the address can receive email. `risk` tells you whether you should send. An address can be `deliverable` but still `high` risk (e.g., a known spam trap or complaint-prone address).
3. **Catch-all domains** -- `catch_all` means the domain accepts email to any address. The specific mailbox may not exist. Treat catch-all results as medium risk.
4. **Disposable addresses** -- `is_disposable_address: true` flags temporary email services. Consider blocking these at signup or flagging for manual review.
5. **Role addresses** -- `is_role_address: true` flags addresses like info@, admin@, support@. These often forward to groups and have higher complaint rates. Avoid marketing sends; transactional is usually fine.
6. **Parallel job limit** -- Maximum 5 bulk validation jobs running simultaneously. Queue additional jobs or wait for completion.
7. **File size limit** -- Bulk validation CSV files must be under 25 MB. For larger lists, split into multiple files.
8. **CSV format** -- Bulk validation CSV files must include a header row with an `email` column. The API expects a properly structured CSV, not a plain list of addresses.
9. **Download URL expiry** -- Bulk validation result download URLs expire. Retrieve results promptly after job completion.
10. **Region consistency** -- Use the same region endpoint (US or EU) as your Mailgun Send account. Validation data does not cross regions.
11. **`did_you_mean` suggestions** -- Single address validation may return a `did_you_mean` field suggesting a corrected address (e.g., `gmial.com` → `gmail.com`). Surface these to users at signup time.
12. **Cost awareness** -- Single address validations and bulk validations consume validation credits. List Health Previews are free. Design workflows to preview first, then validate selectively.
13. **Bulk field name inconsistency** -- Bulk validation summaries use undelimited keys (`donotsend`, `catchall`), while preview summaries and single validation results use underscored keys (`do_not_send`, `catch_all`). Handle both formats when parsing responses.
14. **`X-Mailgun-Account-Id` header** -- Bulk validation GET, LIST, and DELETE endpoints require the `X-Mailgun-Account-Id` header. The POST (create) endpoint does not.
15. **Bulk status is `uploaded`, not `completed`** -- The terminal success status for bulk jobs is `uploaded` (meaning results are uploaded and ready for download), not `completed`. Full lifecycle: `created` → `processing` → `uploading` → `uploaded` (or `failed`).
16. **Engagement data in bulk summaries** -- Bulk validation results may include an `engagement` summary with counts for `highly_engaged`, `engaged`, `bot`, `complainer`, `disengaged`, and `no_data`.
17. **Timestamps are unix integers** -- `created_at` fields return unix timestamps (integers), not ISO 8601 date strings.

## API Reference

### Key Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v4/address/validate` | GET | Validate a single email address |
| `/v4/address/validate/preview` | GET | List all list health preview jobs |
| `/v4/address/validate/preview/{list_id}` | POST | Create a list health preview job |
| `/v4/address/validate/preview/{list_id}` | GET | Get preview job status and results |
| `/v4/address/validate/preview/{list_id}` | PUT | Promote preview to full bulk validation |
| `/v4/address/validate/preview/{list_id}` | DELETE | Delete a preview job |
| `/v4/address/validate/bulk` | GET | List all bulk validation jobs |
| `/v4/address/validate/bulk/{list_id}` | POST | Create a bulk validation job (upload CSV) |
| `/v4/address/validate/bulk/{list_id}` | GET | Get bulk validation job status and results |
| `/v4/address/validate/bulk/{list_id}` | DELETE | Cancel or delete a bulk validation job |
| `/v4/address/validate/jobs` | GET | List all bulk and preview jobs combined |

#### Legacy V3 Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v3/address/validate` | GET, POST | Validate a single address (V3, legacy) |
| `/v3/address/parse` | GET, POST | Parse comma-separated addresses into valid/invalid |
| `/v3/lists/{list_id}/validate` | POST | Start a V3 bulk validation job |
| `/v3/lists/{list_id}/validate` | GET | Get a V3 bulk validation job |
| `/v3/lists/{list_id}/validate` | DELETE | Cancel a V3 bulk validation job |

V3 endpoints are still available but V4 is recommended. The V3 single validation uses `mailbox_verification` (boolean) instead of V4's `provider_lookup`, and returns a different response shape with `is_valid`, `mailbox_verification`, and `parts` fields.

The **Address Parse** endpoint (`/v3/address/parse`) is unique to V3 -- it accepts a comma-separated list of addresses and returns `parsed` (valid) and `unparseable` arrays. Useful for quick syntax validation of multiple addresses without consuming validation credits.

### Single Validation Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `address` | string | Yes | Email address to validate |
| `provider_lookup` | boolean | No | Enable provider-level checks (default: `true`) |

### Single Validation Response (V4)

```json
{
  "address": "test@example.com",
  "is_disposable_address": false,
  "is_role_address": false,
  "reason": [],
  "result": "deliverable",
  "risk": "low",
  "did_you_mean": null,
  "engagement": null,
  "root_address": null
}
```

| Field | Type | Description |
|-------|------|-------------|
| `address` | string | The validated email address |
| `result` | string | `deliverable`, `undeliverable`, `do_not_send`, `catch_all`, or `unknown` |
| `risk` | string | `low`, `medium`, `high`, or `unknown` |
| `is_disposable_address` | boolean | Whether the address uses a disposable email service |
| `is_role_address` | boolean | Whether the address is role-based (info@, admin@, etc.) |
| `reason` | array | Reasons for the result classification |
| `did_you_mean` | string/null | Suggested correction for likely typos |
| `engagement` | object/null | Engagement data: `engaging` (bool), `behavior` (string), `is_bot` (bool) |
| `root_address` | string/null | Canonical form of the address |
| `last_seen` | integer/null | Unix timestamp of last observation (when available) |

## Links

- Documentation: https://documentation.mailgun.com/docs/validate
- API Reference: https://documentation.mailgun.com/docs/validate/openapi-validate-final
- Bulk Validation Guide: https://documentation.mailgun.com/docs/validate/bulk-valid-ir
- List Health Preview: https://documentation.mailgun.com/docs/validate/bulk_valid_preview
- Product Page: https://www.mailgun.com/products/validate/
- Mailgun Dashboard: https://app.mailgun.com
- Help Center: https://help.mailgun.com
- Mailgun LLMs.txt: https://documentation.mailgun.com/llms.txt
- LLMs.txt (full docs index): https://developers.sinch.com/llms.txt
