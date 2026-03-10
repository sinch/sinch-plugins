---
name: send-message
description: Send messages via Sinch Conversation API over WhatsApp, SMS, RCS, Messenger, Viber, Instagram, Telegram, and other channels. Use when the user wants to send a message, text someone, send a WhatsApp message, send an SMS, or communicate via any messaging channel. Automatically handles contact creation and conversation management.
---

# Send Message

Send messages through Sinch Conversation API. Prefer MCP tools if available, otherwise use the Conversation API specification. Supports all channels including WhatsApp, SMS, RCS, MMS, Messenger, Viber, Instagram, Telegram, LINE, WeChat, KakaoTalk, and Apple Messages for Business.

## Instructions

1. **Extract message details from user request:**
   - Recipient: phone number, contact name, or contact ID
   - Message content: text to send
   - Channel preference: WhatsApp, SMS, or other (if specified)
   - Message type: text, media, location, choice, or template
   - If channel not specified, use WhatsApp as default for phone numbers

2. **Check MCP availability and use appropriate method:**

   **Option A: Use MCP tools (if MCP Sinch is configured):**
   - First check if MCP Sinch server is available (check MCP server configuration)
   - If MCP is available, use the appropriate MCP tool:
     - `send-text-message` for text messages
     - `send-media-message` for media messages (images, videos, etc.)
     - `send-location-message` for location messages
     - `send-choice-message` for interactive choice messages
     - `send-template-message` for template messages (use V2 API exclusively — V1 reached end-of-life Jan 31, 2026)
   - MCP tools handle authentication automatically via environment variables
   - If MCP tool execution fails or MCP is not configured, fallback to Option B

   **Option B: Use Conversation API endpoint (fallback if MCP not available):**
   - Endpoint: `POST /v1/projects/{project_id}/messages:send`
   - Operation ID: `Messages_SendMessage`
   - Authentication: Use Basic Auth or OAuth2 with credentials from environment variables (CONVERSATION_PROJECT_ID, CONVERSATION_KEY_ID, CONVERSATION_KEY_SECRET)
   - Region: Use CONVERSATION_REGION environment variable (us, eu, or br)
   - Base URL: `https://{region}.conversation.api.sinch.com`
   - The API will automatically:
     - Create a contact if the recipient doesn't exist
     - Start a conversation if one doesn't exist (CONVERSATION mode)
     - Send the message via the specified channel

3. **Processing modes:**
   - **DISPATCH** (default for new apps) — messages dispatched without conversation context. Use for 1-way and 2-way flows where conversation tracking is not needed.
   - **CONVERSATION** — messages tied to a conversation. Auto-created if none exists. Use when you need conversation history and context.
   - The mode is set on the Conversation API app and affects how messages are listed (`messages_source` parameter) and whether contacts/conversations are auto-created.

4. **Channel properties:**
   - Use `channel_properties` to set channel-specific parameters in the request body.
   - Example: `"channel_properties": { "SMS_SENDER": "+15559876543" }` to set the SMS sender ID.
   - Channel properties are key-value pairs where the key format is `CHANNEL_PROPERTY_NAME`.

5. **Channel priority and fallback:**
   - Set `channel_priority_order` to attempt channels in order. If delivery fails on one channel, the API falls back to the next.
   - You receive a `SWITCH_ON_CHANNEL` delivery report when fallback occurs.
   - Each channel in the priority list needs a matching `channel_identities` entry in the recipient.
   - Fallback billing: you may be billed for each channel attempted.

6. **Message format:**
   - For text messages: Use `text_message` with the message content
   - For media messages: Use `media_message` with `url`
   - For card messages: Use `card_message` with title, description, media, and choices
   - For carousel messages: Use `carousel_message` with an array of cards
   - For choice messages: Use `choice_message` with buttons/quick replies
   - For template messages: Use `template_message` with `template_id` and parameters
   - For location messages: Use `location_message` with coordinates
   - Channel is determined from user request or defaults to WhatsApp

7. **Response handling:**
   - Confirm successful message send with message ID
   - Report any errors clearly
   - If channel is not available, suggest alternatives

## Examples

**Natural language prompts that trigger this Skill:**
- "Send a WhatsApp message to John saying 'Meeting at 3 PM'"
- "Text Alice that I'll be late"
- "Send SMS to +1234567890 with message 'Your order is ready'"
- "Message Bob on WhatsApp: 'Thanks for the update'"
- "Send a message to contact ID abc123 saying 'Hello'"
- "Send a template message to +1234567890 on WhatsApp"
- "Send an image to +1234567890 via RCS"

**MCP Tool Usage (Preferred if available):**
1. Check if MCP Sinch server is configured (MCP server settings)
2. Use appropriate MCP tool based on message type:
   - `send-text-message` for text messages
   - `send-media-message` for media (requires `url` parameter)
   - `send-location-message` for location (requires `address` parameter)
   - `send-choice-message` for interactive choices (requires `choiceContent` array)
   - `send-template-message` for templates (requires `templateId` or `whatsAppTemplateName`)
3. MCP tools automatically use credentials from environment variables
4. If MCP is not available or tool execution fails, fallback to Conversation API

**Conversation API Usage (Fallback):**
1. Use the Conversation API endpoint: `POST /v1/projects/{project_id}/messages:send`
2. Authentication: Use Basic Auth with CONVERSATION_KEY_ID and CONVERSATION_KEY_SECRET, or OAuth2
3. Include required headers: `Authorization`, `Content-Type: application/json`
4. Request body should include: `app_id` (from CONVERSATION_APP_ID), `recipient`, `message` (with appropriate message type), optional `channel_priority_order`, and optional `channel_properties`

**Node.js SDK Example:**
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

**Channel Fallback Example (curl):**
```bash
curl -X POST "https://us.conversation.api.sinch.com/v1/projects/$PROJECT_ID/messages:send" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
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
      "text_message": { "text": "Hello with fallback!" }
    }
  }'
```

## Channel Support

Supported channels:
- **WHATSAPP**: WhatsApp Business messages — 24h service window, template approval required outside window
- **SMS**: SMS text messages — encoding (GSM vs UCS-2), concatenation, sender IDs, opt-out, 10DLC
- **RCS**: Rich Communication Services — rich cards, carousels, choices, capability check, carrier approval
- **MMS**: Multimedia Messaging Service — 1 MB size limit, US/Canada/Australia only
- **MESSENGER**: Facebook Messenger
- **VIBERBM**: Viber Business Messages
- **INSTAGRAM**: Instagram Direct Messages
- **TELEGRAM**: Telegram messages
- **LINE**: LINE messages
- **WECHAT**: WeChat messages
- **KAKAOTALK**: KakaoTalk messages
- **APPLEBC**: Apple Messages for Business

## Executable Scripts

Bundled Node.js scripts for sending messages. All scripts use OAuth2 authentication and read credentials from environment variables.

**Required environment variables:**
```bash
export SINCH_PROJECT_ID="your-project-id"
export SINCH_KEY_ID="your-key-id"
export SINCH_KEY_SECRET="your-key-secret"
export SINCH_APP_ID="your-app-id"
export SINCH_REGION="us"  # optional, default: us (us|eu|br)
```

**SMS:**

| Script | Description | Example |
|--------|-------------|---------|
| `scripts/sms/send_sms.cjs` | Send SMS message | `node scripts/sms/send_sms.cjs --to +15551234567 --message "Hello"` |

**RCS:**

| Script | Description | Example |
|--------|-------------|---------|
| `scripts/rcs/send_text.cjs` | Send RCS text | `node scripts/rcs/send_text.cjs --to +15551234567 --message "Hello"` |
| `scripts/rcs/send_card.cjs` | Send RCS rich card | `node scripts/rcs/send_card.cjs --to +15551234567 --title "Sale" --image-url URL` |
| `scripts/rcs/send_carousel.cjs` | Send RCS carousel | `node scripts/rcs/send_carousel.cjs --to +15551234567 --cards '[...]'` |
| `scripts/rcs/send_choice.cjs` | Send RCS choice | `node scripts/rcs/send_choice.cjs --to +15551234567 --message "Pick" --choices "A,B"` |
| `scripts/rcs/send_media.cjs` | Send media message | `node scripts/rcs/send_media.cjs --to +15551234567 --url URL` |
| `scripts/rcs/send_location.cjs` | Send location | `node scripts/rcs/send_location.cjs --to +15551234567 --lat 55.61 --lon 13.00` |
| `scripts/rcs/send_template.cjs` | Send template message | `node scripts/rcs/send_template.cjs --to +15551234567 --template-id ID` |

## Code Generation References

When generating code, use the appropriate reference file for the user's language and message type:

**SMS examples:** [references/sms/](references/sms/) — TypeScript, Python, Java

**RCS examples (by message type):**
- [references/rcs/text-message/](references/rcs/text-message/) — JavaScript, Python, Java
- [references/rcs/card-message/](references/rcs/card-message/)
- [references/rcs/carousel-message/](references/rcs/carousel-message/)
- [references/rcs/choice-message/](references/rcs/choice-message/)
- [references/rcs/media-message/](references/rcs/media-message/)
- [references/rcs/location-message/](references/rcs/location-message/)
- [references/rcs/template-message/](references/rcs/template-message/)

**Channel-specific guides:**
- [references/channels/sms.md](references/channels/sms.md) — encoding, concatenation, sender IDs, opt-out, 10DLC
- [references/channels/whatsapp.md](references/channels/whatsapp.md) — 24h service window, template approval, opt-in
- [references/channels/rcs.md](references/channels/rcs.md) — rich cards, carousels, choices, capability check
- [references/channels/mms.md](references/channels/mms.md) — media types, 1 MB limit, US/Canada/Australia

**Templates:** [references/templates.md](references/templates.md) — V2 template management, dynamic parameters, channel overrides

**Batch sending:** [references/batch.md](references/batch.md) — up to 1000 recipients, per-recipient substitution

## Batch Sending

The Batch API sends a single message definition to up to 1000 recipients in one API call, with per-recipient `${parameter}` substitution. Uses a separate base URL: `conversationbatch.api.sinch.com`. See [references/batch.md](references/batch.md) for full details.

## Gotchas

- **Region must match.** Your Conversation API app must be in the same region as your service plans and channel configurations. Mismatched regions cause silent failures or 404 errors.
- **Rate limits.** Projects are limited to 800 requests/second across all apps and endpoints. Error code 429 when exceeded.
- **OAuth tokens expire in ~1 hour.** Cache and refresh tokens proactively. Never use Basic Auth in production (heavily rate limited).
- **Channel transcoding is automatic but lossy.** Rich messages (cards, carousels) sent to channels that do not support them are transcoded to text. Test across target channels.
- **Fallback billing.** When fallback triggers, you may be billed for each channel attempted. Configure fallback deliberately.
- **Contact auto-creation.** When sending messages, the API automatically creates a contact if the recipient doesn't exist and starts a conversation if one doesn't exist.
- **Max 5 webhooks per app.** Plan webhook trigger assignments carefully.

## Notes

- **Prefer MCP tools** if MCP Sinch is configured — they provide a simpler interface and handle authentication automatically
- **Fallback to Conversation API** if MCP is not configured or MCP tool execution fails
- Recipients can be identified by phone number (with country code), contact ID, or contact name
- If a contact doesn't exist, one will be created automatically
- Messages are added to existing conversations or new conversations are created automatically
- For MCP: Use the appropriate tool based on message type (text, media, location, choice, template)
- For Conversation API: Use `text_message` for text, `template_message` with `template_id` for templates
- Channel can be specified in `channel_priority_order` or determined automatically
- Use `channel_properties` for channel-specific settings like SMS sender ID
