---
name: sinch-conversation-api
description: "Build omnichannel messaging with Sinch Conversation API. One unified API to send and receive messages on SMS, WhatsApp, RCS, MMS, Viber, Messenger, and more. Use when sending texts, WhatsApp messages, rich cards, carousels, templates, batch messages, or building multi-channel messaging."
---

# Sinch Conversation API

## Overview

The Sinch Conversation API is an omnichannel messaging platform that provides a single, unified API to send and receive messages across SMS, WhatsApp, RCS, MMS, Viber Business, Facebook Messenger, Instagram, Telegram, KakaoTalk, LINE, WeChat, and more.

Key value: write one API call, reach customers on any channel. The API handles transcoding between a generic message format and channel-specific formats automatically.

## Agent Instructions

Before generating any code, you MUST ask the user the following clarifying questions upfront (in a single prompt):

1. **Approach** — Do you want to use the **Conversation API SDK** or make **direct API calls** (plain HTTP using `fetch`, `axios`, `curl`, etc.)?

   SDK documentation by language:
   - [Node.js SDK Reference](https://developers.sinch.com/docs/conversation/sdk/node/syntax-reference)
   - [Python SDK Reference](https://developers.sinch.com/docs/conversation/sdk/python/syntax-reference)
   - [Java SDK Reference](https://developers.sinch.com/docs/conversation/sdk/java/syntax-reference)
   - [.NET SDK Reference](https://developers.sinch.com/docs/conversation/sdk/dotnet/syntax-reference)

2. **Language** — Which programming language? (Node.js, Python, Java, .NET/C#, curl/bash, etc.)

Do not assume defaults or skip these questions. Wait for the user's answers before generating any code.

When the user chooses **SDK**, fetch the corresponding SDK reference page for the chosen language to get accurate syntax and method signatures. When the user chooses **direct API calls**, use the REST API with `fetch`/`axios`/`requests`/`HttpClient` as appropriate for the language.

## Getting Started

### Authentication

See the [sinch-authentication](../authentication/SKILL.md) skill for full auth setup, SDK initialization, and dashboard links.

The API supports two auth methods:

**OAuth 2.0 (recommended for production):**

```bash
curl -X POST https://auth.sinch.com/oauth2/token \
  -d grant_type=client_credentials \
  -u YOUR_KEY_ID:YOUR_KEY_SECRET
```

Response returns `access_token` (valid ~1 hour). Use as `Authorization: Bearer <access_token>`.

**Basic Auth (testing only — heavily rate limited):**

```bash
-u YOUR_KEY_ID:YOUR_KEY_SECRET
```

You need three credentials from the Sinch Build Dashboard:

- **Project ID** — found on the Project Settings page
- **Key ID** — generated when creating an access key
- **Key Secret** — shown once during access key creation (save it immediately)

### Base URL

The API is regional. Use the region matching your Conversation API app:

| Region | Base URL                                |
| ------ | --------------------------------------- |
| US     | `https://us.conversation.api.sinch.com` |
| EU     | `https://eu.conversation.api.sinch.com` |
| BR     | `https://br.conversation.api.sinch.com` |

### SDK Installation

| Language | Package                                   | Install                       |
| -------- | ----------------------------------------- | ----------------------------- |
| Node.js  | `@sinch/sdk-core` + `@sinch/conversation` | `npm install @sinch/sdk-core` |
| Java     | `com.sinch.sdk:sinch-sdk-java`            | Maven dependency              |
| Python   | `sinch`                                   | `pip install sinch`           |
| .NET     | `Sinch`                                   | `dotnet add package Sinch`    |

### First API Call — Send a Text Message

**curl:**

```bash
curl -X POST "https://us.conversation.api.sinch.com/v1/projects/$PROJECT_ID/messages:send" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "recipient": {
      "identified_by": {
        "channel_identities": [{
          "channel": "SMS",
          "identity": "+15551234567"
        }]
      }
    },
    "message": {
      "text_message": {
        "text": "Hello from Sinch Conversation API!"
      }
    },
    "channel_properties": {
      "SMS_SENDER": "+15559876543"
    }
  }'
```

**Node.js SDK:**

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: "YOUR_PROJECT_ID",
  keyId: "YOUR_KEY_ID",
  keySecret: "YOUR_KEY_SECRET",
});

const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: "YOUR_APP_ID",
    recipient: {
      identified_by: {
        channel_identities: [{ channel: "SMS", identity: "+15551234567" }],
      },
    },
    message: {
      text_message: { text: "Hello from Sinch Conversation API!" },
    },
    channel_properties: { SMS_SENDER: "+15559876543" },
  },
});
```

## Key Concepts

### Apps

A Conversation API app is the top-level container. Each app can have multiple channel integrations (SMS, WhatsApp, RCS, etc.). Created via the Sinch Build Dashboard or API.

### Contacts

A contact represents an end-user. Each contact can have multiple channel identities (phone number for SMS, WhatsApp number, etc.). Contacts are scoped to a project.

### Conversations

A conversation is a thread between your app and a contact. Conversations track message history and state across channels.

### Messages

Messages use a generic format that the API transcodes per channel:

- **Text message** — plain text
- **Media message** — image, video, audio, document
- **Card message** — rich card with media, title, description, and buttons
- **Carousel message** — multiple cards in a swipeable layout
- **Choice message** — buttons/quick replies
- **Template message** — pre-approved templates (required for WhatsApp outside 24h window)
- **Location message** — geographic coordinates

### Processing Modes

- **DISPATCH** (default for new apps) — no conversation created. Messages dispatched without conversation context. Use for 1-way and 2-way flows.
- **CONVERSATION** — messages tied to a conversation. Auto-created if none exists.

The mode affects how messages are listed (`messages_source` parameter) and whether contacts/conversations are auto-created.

### Channel Priority and Fallback

Set `channel_priority_order` to attempt channels in order. If delivery fails on one channel, the API falls back to the next. You receive a `SWITCH_ON_CHANNEL` delivery report when fallback occurs.

```json
{
  "app_id": "YOUR_APP_ID",
  "channel_priority_order": ["RCS", "WHATSAPP", "SMS"],
  "recipient": {
    "identified_by": {
      "channel_identities": [
        { "channel": "RCS", "identity": "+15551234567" },
        { "channel": "WHATSAPP", "identity": "+15551234567" },
        { "channel": "SMS", "identity": "+15551234567" }
      ]
    }
  },
  "message": {
    "text_message": { "text": "Text message from Sinch Conversation API." }
  }
}
```

## Channels

The Conversation API supports these channels. Each has channel-specific behaviors documented in the reference files:

| Channel       | Reference                                                          | Key Considerations                                                 |
| ------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------ |
| **SMS**       | [references/channels/sms.md](references/channels/sms.md)           | Encoding (GSM vs UCS-2), concatenation, sender IDs, opt-out, 10DLC |
| **WhatsApp**  | [references/channels/whatsapp.md](references/channels/whatsapp.md) | 24h service window, template approval, opt-in requirements         |
| **RCS**       | [references/channels/rcs.md](references/channels/rcs.md)           | Rich cards, carousels, choices, capability check, carrier approval |
| **MMS**       | [references/channels/mms.md](references/channels/mms.md)           | Media types, 1 MB size limit, US/Canada/Australia only             |
| **Viber**     | —                                                                  | Viber Business Messages                                            |
| **Messenger** | —                                                                  | Facebook Messenger                                                 |
| **Instagram** | —                                                                  | Instagram Direct Messages                                          |
| **Telegram**  | —                                                                  | Telegram messages                                                  |
| **KakaoTalk** | —                                                                  | KakaoTalk messages                                                 |
| **LINE**      | —                                                                  | LINE messages                                                      |
| **WeChat**    | —                                                                  | WeChat messages                                                    |

## Templates

The Template Management API manages omni-channel templates with dynamic parameters, multiple languages, and channel-specific overrides (e.g., WhatsApp-approved templates).

**Use V2 exclusively** — V1 reached end-of-life on January 31, 2026.

Templates use a separate base URL (`template.api.sinch.com`). For full details on creating, updating, querying templates, translation properties, channel overrides, and V1-to-V2 migration, see [references/templates.md](references/templates.md).

## Batch Sending

The Batch API sends a single message definition to up to 1000 recipients in one API call, with per-recipient `${parameter}` substitution. Also supports bulk contact creation/deletion and consent records.

The Batch API uses a separate base URL (`conversationbatch.api.sinch.com`). For the full request structure (including the correct vs wrong format), field reference, examples, and managing/cancelling batches, see [references/batch.md](references/batch.md).

## Webhooks

Webhooks deliver callbacks to your server for:

- **Message delivery reports** — status updates (QUEUED, DELIVERED, READ, FAILED)
- **Inbound messages** — messages from contacts
- **Events** — typing indicators, contact events, conversation events

### Webhook Configuration

- Create up to 5 webhooks per app
- Subscribe to 22 different event triggers
- Support for OAuth2.0 and HMAC authentication
- Automatic retry with exponential backoff

### Webhook Triggers

**Message:** `MESSAGE_INBOUND`, `MESSAGE_DELIVERY`, `MESSAGE_SUBMIT`, `MESSAGE_INBOUND_SMART_CONVERSATION_REDACTION`

**Event:** `EVENT_INBOUND`, `EVENT_DELIVERY`

**Conversation:** `CONVERSATION_START`, `CONVERSATION_STOP`, `CONVERSATION_DELETE`

**Contact:** `CONTACT_CREATE`, `CONTACT_UPDATE`, `CONTACT_DELETE`, `CONTACT_MERGE`, `CONTACT_IDENTITIES_DUPLICATION`

**Capability & Opt:** `CAPABILITY`, `OPT_IN`, `OPT_OUT`

**System:** `CHANNEL_EVENT`, `BATCH_STATUS_UPDATE`, `RECORD_NOTIFICATION`, `SMART_CONVERSATION`, `UNSUPPORTED`

### HMAC Signature Validation

Verify using headers: `x-sinch-webhook-signature`, `x-sinch-webhook-signature-timestamp`, `x-sinch-webhook-signature-nonce`, `x-sinch-webhook-signature-algorithm`.

Signature format: `HMAC-SHA256(rawBody + '.' + nonce + '.' + timestamp, secret)`

### Register a Webhook

```bash
curl -X POST "https://us.conversation.api.sinch.com/v1/projects/$PROJECT_ID/webhooks" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "target": "https://your-server.com/webhook",
    "target_type": "HTTP",
    "triggers": ["MESSAGE_DELIVERY", "MESSAGE_INBOUND", "EVENT_INBOUND"]
  }'
```

### Webhook Scripts

Pre-built scripts in `scripts/webhooks/`:

```bash
node scripts/webhooks/create_webhook.cjs --app-id APP_ID --target https://your-server.com/webhook --triggers MESSAGE_INBOUND,MESSAGE_DELIVERY
node scripts/webhooks/list_webhooks.cjs --app-id APP_ID
node scripts/webhooks/get_webhook.cjs --webhook-id WEBHOOK_ID
node scripts/webhooks/update_webhook.cjs --webhook-id WEBHOOK_ID --target https://new-url.com/webhook --triggers MESSAGE_INBOUND
node scripts/webhooks/delete_webhook.cjs --webhook-id WEBHOOK_ID
node scripts/webhooks/test_webhook_triggers.cjs --webhook-id WEBHOOK_ID --test-url https://webhook.site/your-id
```

For detailed webhook guides, multi-language examples, trigger payload references, and testing scripts, see `references/webhooks/`.

## Executable Scripts

Bundled Node.js scripts for sending and listing messages. All scripts use OAuth2 authentication, require no external dependencies, and read credentials from environment variables.

### Required Environment Variables

```bash
export SINCH_PROJECT_ID="your-project-id"
export SINCH_KEY_ID="your-key-id"
export SINCH_KEY_SECRET="your-key-secret"
export SINCH_APP_ID="your-app-id"        # required for sending only
export SINCH_REGION="us"                   # optional, default: us (us|eu|br)
```

### Available Scripts

**SMS:**

| Script | Description | Example |
|--------|-------------|---------|
| `sms/send_sms.cjs` | Send SMS message | `node scripts/sms/send_sms.cjs --to +15551234567 --message "Hello"` |

**RCS:**

| Script | Description | Example |
|--------|-------------|---------|
| `rcs/send_text.cjs` | Send RCS text | `node scripts/rcs/send_text.cjs --to +15551234567 --message "Hello"` |
| `rcs/send_card.cjs` | Send RCS rich card | `node scripts/rcs/send_card.cjs --to +15551234567 --title "Sale" --image-url URL` |
| `rcs/send_carousel.cjs` | Send RCS carousel | `node scripts/rcs/send_carousel.cjs --to +15551234567 --cards '[...]'` |
| `rcs/send_choice.cjs` | Send RCS choice | `node scripts/rcs/send_choice.cjs --to +15551234567 --message "Pick" --choices "A,B"` |
| `rcs/send_media.cjs` | Send media message | `node scripts/rcs/send_media.cjs --to +15551234567 --url URL` |
| `rcs/send_location.cjs` | Send location | `node scripts/rcs/send_location.cjs --to +15551234567 --lat 55.61 --lon 13.00` |
| `rcs/send_template.cjs` | Send template message | `node scripts/rcs/send_template.cjs --to +15551234567 --template-id ID` |

**General:**

| Script | Description | Example |
|--------|-------------|---------|
| `common/list_messages.cjs` | List/retrieve messages | `node scripts/common/list_messages.cjs --channel SMS --page-size 20` |

## Code Generation

When the user asks to generate code, first ask about **approach** (SDK vs direct API) and **language** (see Agent Instructions above), then use the appropriate reference files:

### SMS Code Examples

- **TypeScript/Node.js**: [references/sms/typescript-examples.md](references/sms/typescript-examples.md)
- **Python**: [references/sms/python-examples.md](references/sms/python-examples.md)
- **Java**: [references/sms/java-examples.md](references/sms/java-examples.md)

### RCS Code Examples (by message type)

Each RCS message type has separate reference files per language:

- **Text**: [references/rcs/text-message/](references/rcs/text-message/) (javascript, python, java)
- **Card**: [references/rcs/card-message/](references/rcs/card-message/)
- **Carousel**: [references/rcs/carousel-message/](references/rcs/carousel-message/)
- **Choice**: [references/rcs/choice-message/](references/rcs/choice-message/)
- **Media**: [references/rcs/media-message/](references/rcs/media-message/)
- **Location**: [references/rcs/location-message/](references/rcs/location-message/)
- **List Messages**: [references/rcs/list-messages/](references/rcs/list-messages/)
- **Template**: [references/rcs/template-message/](references/rcs/template-message/)

### Webhook Code Examples

- See [references/webhooks/](references/webhooks/) for create, list, get, update, delete examples in JavaScript, Python, and Java.

### Usage Guidelines

1. **Detect the message type** from the user's request (text, card, carousel, choice, media, location)
2. **Identify the target language** from the user's request or context
3. **Read only the specific reference file** for that message type and language
4. **SDK approach**: Use SDK examples and fetch the SDK reference page for the chosen language
5. **Direct API approach**: Use raw HTTP examples with `fetch`/`axios`/`requests`/`HttpClient`

## Common Patterns

### Identify Recipient by Contact ID

```json
{ "recipient": { "contact_id": "CONTACT_ID" } }
```

### Send a Media Message

```json
{
  "message": {
    "media_message": { "url": "https://example.com/image.jpg" }
  }
}
```

### Send a Card Message

```json
{
  "message": {
    "card_message": {
      "title": "Welcome!",
      "description": "Check out our latest offer.",
      "media_message": { "url": "https://example.com/promo.jpg" },
      "choices": [
        {
          "text_message": { "text": "Learn More" },
          "postback_data": "learn_more"
        }
      ]
    }
  }
}
```

## Gotchas and Best Practices

1. **Region must match.** Your Conversation API app must be in the same region as your service plans and channel configurations. Mismatched regions cause silent failures.

2. **Rate limits.** Projects are limited to 800 requests/second across all apps and endpoints.

3. **OAuth tokens expire in ~1 hour.** Cache and refresh tokens proactively. Never use Basic Auth in production.

4. **Channel transcoding is automatic but lossy.** Rich messages (cards, carousels) sent to channels that do not support them are transcoded to text. Test across target channels.

5. **Webhook reliability.** Implement idempotent webhook handlers. Sinch may retry failed deliveries.

6. **Fallback billing.** When fallback triggers, you may be billed for each channel attempted. Configure fallback deliberately.

7. **Do not hardcode credentials.** Load `projectId`, `keyId`, and `keySecret` from environment variables.

8. **Contact auto-creation.** When sending messages, the API automatically creates a contact if the recipient doesn't exist and starts a conversation if one doesn't exist.

9. **Common error codes:** `400` malformed request, `401` invalid credentials, `403` no access or billing limit, `404` resource not found or region mismatch, `429` rate limit exceeded, `500/503` server errors (retry with backoff).

10. **Max 5 webhooks per app.** Plan webhook trigger assignments carefully.

## Links

- [Getting Started](https://developers.sinch.com/docs/conversation/getting-started.md)
- [API Reference](https://developers.sinch.com/docs/conversation/api-reference/conversation.md)
- [Key Concepts](https://developers.sinch.com/docs/conversation/keyconcepts.md)
- [Message Types](https://developers.sinch.com/docs/conversation/message-types.md)
- [Channel Support](https://developers.sinch.com/docs/conversation/channel-support.md)
- [Callbacks](https://developers.sinch.com/docs/conversation/callbacks.md)
- [Node.js SDK Reference](https://developers.sinch.com/docs/conversation/sdk/node/syntax-reference)
- [Python SDK Reference](https://developers.sinch.com/docs/conversation/sdk/python/syntax-reference)
- [Java SDK Reference](https://developers.sinch.com/docs/conversation/sdk/java/syntax-reference)
- [.NET SDK Reference](https://developers.sinch.com/docs/conversation/sdk/dotnet/syntax-reference)
- [Node.js SDK (GitHub)](https://github.com/sinch/sinch-sdk-node)
- [Conversation API OpenAPI Spec (YAML)](https://developers.sinch.com/_bundle/docs/conversation/api-reference/conversation.yaml?download)
- [LLMs.txt (full docs index)](https://developers.sinch.com/llms.txt)
