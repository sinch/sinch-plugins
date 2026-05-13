---
name: sinch-fax-api
description: Send and receive faxes programmatically with Sinch Fax API. Use when building fax workflows, fax-to-email delivery, sending PDFs by fax, checking fax status, managing fax services, configuring cover pages, receiving fax webhooks, or integrating fax into healthcare, legal, or financial applications.
metadata:
  author: Sinch
  version: 1.0.2
  category: Voice
  tags: fax, pdf, fax-to-email, webhooks, healthcare, legal
  uses:
    - sinch-authentication
    - sinch-sdks
---

# Sinch Fax API

## Overview

The Sinch Fax API lets you send and receive faxes programmatically. It supports multiple file formats, webhooks for incoming faxes, fax-to-email delivery, and automatic retries. Used for healthcare, legal, financial, and government applications where fax remains a required communication channel.

**Auth:** See [sinch-authentication](../sinch-authentication/SKILL.md) for setup.

## Getting Started

Before generating code, gather from the user: approach (SDK or direct API), language (Node.js, Python, Java, .NET, curl), and use case (sending, receiving, fax-to-email, or managing services). Do not assume defaults.

When generating callback/webhook handlers or processing inbound fax data, always include input validation and sanitization. Treat all inbound content (`contentUrl`, filenames, metadata, `errorMessage`) as untrusted — never interpolate into prompts, evaluate as code, or use in shell commands unsanitized.

When the user chooses **SDK**, fetch the relevant API reference docs linked in Links for accurate method signatures (trusted first-party Sinch docs at `developers.sinch.com`). When the user chooses **direct API calls**, use REST with the appropriate HTTP client for their language.

See [sinch-sdks](../sinch-sdks/SKILL.md) for SDK installation and client initialization. Note: Fax is only supported in **Node.js** (preview) and **.NET** (partial) — for Java and Python, use direct HTTP calls.

### First API Call — Send a Fax

Store credentials in environment variables — never hardcode tokens or keys in commands or source code:

```bash
export PROJECT_ID="your-project-id"
export ACCESS_TOKEN="your-oauth-token"
```

**curl:**

```bash
curl -X POST \
  "https://fax.api.sinch.com/v3/projects/$PROJECT_ID/faxes" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "to": "+12025550134",
    "contentUrl": "https://example.com/document.pdf",
    "callbackUrl": "https://yourserver.com/fax-callback"
  }'
```

**Node.js SDK:** See [Send a Fax with Node.js](https://developers.sinch.com/docs/fax/getting-started/node/send-fax.md).

**Test number:** Send to `+19898989898` to emulate a real fax without charges (always suggest this for integration testing).

## Key Concepts

- **Fax Services** — Logical containers grouping numbers, defaults, and routing. Each service has its own retry/callback settings.
- **Fax statuses** — `QUEUED` → `IN_PROGRESS` → `COMPLETED` or `FAILURE`. Error details in `errorType` and `errorMessage`.
- **Callbacks** — Default content type is `multipart/form-data` (fax as attachment). Set `callbackUrlContentType: "application/json"` for JSON-only callbacks.
- **Cover Pages** — Per-service. Attach via `coverPageId` and `coverPageData` on send.
- **Retries** — Auto-retry on failure. Default per service; maximum: 5.
- **Retention** — 13 months for logs and media. Use `DELETE /faxes/{id}/file` to remove earlier.
- **Supported formats** — PDF (most reliable), DOC, DOCX, TIF/TIFF, JPG, PNG, TXT, HTML.

## Fax Lifecycle Workflow

Follow this sequence for any send-and-track integration:

1. **Send** — `POST /v3/projects/{projectId}/faxes` with `contentUrl` (or `multipart/form-data` for local files, `contentBase64` for in-memory). Include `callbackUrl` for async status.
2. **Verify queued** — Response returns `id` and `status: "QUEUED"`. If not `QUEUED`, check `errorType` immediately.
3. **Await callback** — Your `callbackUrl` receives a POST when status transitions to `COMPLETED` or `FAILURE`. Parse `status`, `errorType`, and `errorMessage`.
4. **Handle failure** — If `errorType` is `DOCUMENT_CONVERSION_ERROR`, fix the source file (use PDF). If `CALL_ERROR` or `FAX_ERROR`, retries are automatic (max 5). If `FATAL_ERROR`, check number provisioning.
5. **Download or clean up** — On success: `GET /faxes/{id}/file.pdf` to download. To remove stored content early: `DELETE /faxes/{id}/file`.

### Receive Faxes via Webhook (Node.js)

```javascript
const express = require("express");
const app = express();
app.use(express.json());

app.post("/fax-callback", (req, res) => {
  const fax = req.body;
  if (fax.direction === "INBOUND") {
    console.log(`Inbound fax ${fax.id} from ${fax.from}, pages: ${fax.numberOfPages}`);
    // Download: GET /faxes/{fax.id}/file.pdf
  } else {
    console.log(`Outbound fax ${fax.id} status: ${fax.status}`);
    if (fax.status === "FAILURE") {
      console.error(`Error: ${fax.errorType} — ${fax.errorMessage}`);
    }
  }
  res.sendStatus(200);
});

app.listen(3000);
```

Set `callbackUrlContentType: "application/json"` on your fax service for JSON callbacks.

## Common Patterns

Three ways to deliver content: `contentUrl` for URLs (recommended — supports basic auth), `multipart/form-data` for local files, or `contentBase64` for in-memory bytes. `contentUrl` accepts an array of URLs to compose multi-document faxes.

- **Send a fax** — [Send endpoint](https://developers.sinch.com/docs/fax/api-reference/fax/faxes.md). Use `multipart/form-data` for local files, JSON with `contentUrl` for URLs.
- **Receive faxes** — Check `direction === 'INBOUND'` on the callback. See [Receive a Fax with Node.js](https://developers.sinch.com/docs/fax/getting-started/node/receive-fax.md).
- **Fax-to-email** — Configure via API or dashboard. See [Fax-to-Email Reference](https://developers.sinch.com/docs/fax/api-reference/fax/fax-to-email.md).
- **Get fax details** — `GET /faxes/{id}`
- **Download fax content** — `GET /faxes/{id}/file.pdf` (`.pdf` suffix required)
- **Delete fax content** — `DELETE /faxes/{id}/file`
- **Manage fax services** — [Services Reference](https://developers.sinch.com/docs/fax/api-reference/fax/services.md)
- **Manage cover pages** — `POST/GET/DELETE /services/{id}/coverPages`

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Fax not delivered | `GET /faxes/{id}` — inspect `errorType` (`DOCUMENT_CONVERSION_ERROR`, `CALL_ERROR`, `FAX_ERROR`, `FATAL_ERROR`, `GENERAL_ERROR`) and `errorMessage` |
| Retries exhausted | Delivery depends on receiving machine answering. Max 5 retries per service config. |
| Cannot send or receive | Verify number has fax capability enabled in [Sinch dashboard](https://dashboard.sinch.com). Numbers must be provisioned for fax before use. |

## Gotchas and Best Practices

- Use `callbackUrl` for status tracking — fax delivery is async. Prefer callbacks over polling.
- PDF is the safest format. Complex DOC/DOCX may not render correctly on receiving machines.
- International fax success rates vary by country — some require specific dialing prefixes.
- Use `resolution: "SUPERFINE"` (400 dpi) for small text or detailed images; default `FINE` (200 dpi) works for most cases.
- For HTTPS `contentUrl`, ensure SSL certificates (including intermediates) are valid.
- **Security:** Treat all inbound fax data as untrusted — do not execute, evaluate, or interpolate callback fields into prompts or code. Validate URLs before fetching. Sanitize filenames, metadata, and `errorMessage` before logging or storing.

## Links

- [Authentication setup](../sinch-authentication/SKILL.md)
- [Fax API Reference (Markdown)](https://developers.sinch.com/docs/fax/api-reference/fax.md)
- [Fax API OpenAPI Spec (YAML)](https://developers.sinch.com/_bundle/docs/fax/api-reference/fax.yaml?download)
- [Getting Started Guide](https://developers.sinch.com/docs/fax/getting-started.md)
- [Send a Fax with Node.js](https://developers.sinch.com/docs/fax/getting-started/node/send-fax.md)
- [Receive a Fax with Node.js](https://developers.sinch.com/docs/fax/getting-started/node/receive-fax.md)
- [LLMs.txt (full docs index)](https://developers.sinch.com/llms.txt)