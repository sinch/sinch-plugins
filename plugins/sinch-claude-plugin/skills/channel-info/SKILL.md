---
name: channel-info
description: Check available messaging channels, channel capabilities, and channel configuration for Sinch Conversation API. Use when the user asks which channels are available, what channels can be used, how to reach someone, what messaging options exist, or channel capabilities for a contact or app.
---

# Channel Information

Retrieve information about available messaging channels and their capabilities. Prefer MCP tools if available, otherwise use the Conversation API specification. Helps determine which channels can be used to reach contacts.

## Instructions

1. **Understand the user's query:**
   - Are they asking about available channels in general?
   - Are they asking which channels can reach a specific contact?
   - Are they asking about channel capabilities or configuration?

2. **Check MCP availability and use appropriate method:**

   **Option A: Use MCP tools (if MCP Sinch is configured):**
   - First check if MCP Sinch server is available (check MCP server configuration)
   - If MCP is available, use:
     - `list-conversation-apps` to get list of apps and their channel configurations
   - MCP tools handle authentication automatically via environment variables
   - If MCP tool execution fails or MCP is not configured, fallback to Option B

   **Option B: Use Conversation API endpoints (fallback if MCP not available):**
   - **List apps**: `GET /v1/projects/{project_id}/apps` (Operation ID: `App_ListApps`) - Shows configured apps and their channel settings
   - **Get contact**: `GET /v1/projects/{project_id}/contacts/{contact_id}` (Operation ID: `Contact_GetContact`) - Shows which channels are associated with a contact
   - **List contacts**: `GET /v1/projects/{project_id}/contacts` (Operation ID: `Contact_ListContacts`) - Can filter by channel to see contacts on specific channels
   - **Query capability**: `POST /v1/projects/{project_id}/capability:query` (Operation ID: `Capability_QueryCapability`) - Asynchronously checks which channels can reach a contact
   - Authentication: Use Basic Auth or OAuth2 with credentials from environment variables
   - Region: Use CONVERSATION_REGION environment variable (us, eu, or br)
   - Base URL: `https://{region}.conversation.api.sinch.com`

3. **Consider the processing mode:**
   - **DISPATCH** (default for new apps) — messages dispatched without conversation context. Use for 1-way and 2-way flows where conversation tracking is not needed.
   - **CONVERSATION** — messages tied to a conversation. Auto-created if none exists.
   - The processing mode affects how channels are used and whether contacts/conversations are auto-created.

4. **Provide comprehensive channel information:**
   - List all available channels: WhatsApp, SMS, RCS, MMS, Messenger, Viber, Instagram, Telegram, LINE, WeChat, KakaoTalk, Apple Messages for Business
   - For contacts: Show which channels are configured for that contact
   - Explain channel capabilities and use cases
   - Indicate channel availability status

## Examples

**Natural language prompts that trigger this Skill:**
- "Which channels can I use to reach Bob?"
- "What messaging channels are available?"
- "Show me available channels for contact abc123"
- "What channels does this app support?"
- "Can I send WhatsApp messages?"
- "What are my messaging options?"

**MCP Tool Usage (Preferred if available):**
1. Check if MCP Sinch server is configured (MCP server settings)
2. Use `list-conversation-apps` MCP tool to get apps and their channel configurations
3. MCP tools automatically use credentials from environment variables
4. If MCP is not available or tool execution fails, fallback to Conversation API

**Conversation API Usage (Fallback):**
1. Use the Conversation API endpoints for channel information (see endpoints above)
2. Authentication: Use Basic Auth with CONVERSATION_KEY_ID and CONVERSATION_KEY_SECRET, or OAuth2
3. Include required headers: `Authorization`, `Content-Type: application/json`
4. For capability query, note it's asynchronous - results are delivered via webhook callbacks with trigger `CAPABILITY`
5. App responses include channel configuration and credentials status
6. Contact responses include `channel_identities` array showing all associated channels

## Supported Channels

| Channel           | Key Considerations                                                       |
| ----------------- | ------------------------------------------------------------------------ |
| **SMS**           | Encoding (GSM vs UCS-2), concatenation, sender IDs, opt-out, 10DLC      |
| **WHATSAPP**      | 24h service window, template approval, opt-in requirements               |
| **RCS**           | Rich cards, carousels, choices, capability check, carrier approval       |
| **MMS**           | Media types, 1 MB size limit, US/Canada/Australia only                   |
| **MESSENGER**     | Facebook Messenger — rich media, quick replies                           |
| **VIBERBM**       | Viber Business Messages — rich media, carousels                          |
| **INSTAGRAM**     | Instagram Direct Messages — rich media, stories                          |
| **TELEGRAM**      | Telegram messages — rich media, bots                                     |
| **KAKAOTALK**     | KakaoTalk messages — rich media, plus friends                            |
| **KAKAOTALKCHAT** | KakaoTalk chat channel (ConsultationTalk)                                |
| **LINE**          | LINE messages — rich media, stickers                                     |
| **WECHAT**        | WeChat messages — rich media, mini programs                              |
| **APPLEBC**       | Apple Messages for Business — rich media, Apple Pay                      |

## Channel Reference Guides

Detailed channel-specific documentation is available in `references/channels/`:

- [references/channels/sms.md](references/channels/sms.md) — encoding (GSM vs UCS-2), concatenation, sender IDs, opt-out, 10DLC
- [references/channels/whatsapp.md](references/channels/whatsapp.md) — 24h service window, template approval, opt-in requirements
- [references/channels/rcs.md](references/channels/rcs.md) — rich cards, carousels, choices, capability check, carrier approval
- [references/channels/mms.md](references/channels/mms.md) — media types, 1 MB size limit, US/Canada/Australia only

## Channel Capabilities

Each channel supports different message types:
- **Text messages**: All channels
- **Rich media**: Images, videos, audio (channel-dependent)
- **Templates**: Pre-approved message templates (channel-dependent)
- **Interactive messages**: Buttons, quick replies (channel-dependent)
- **Location sharing**: Some channels
- **File attachments**: Channel-dependent
- **Channel transcoding**: Rich messages sent to channels that don't support them are auto-transcoded to text

## Notes

- **Prefer MCP tools** if MCP Sinch is configured — use `list-conversation-apps` for app and channel information
- **Fallback to Conversation API** if MCP is not configured or MCP tool execution fails
- Channel availability depends on app configuration and credentials
- Contacts can have multiple channels associated
- Some channels require specific setup and approval
- Capability query is asynchronous — use webhook callbacks to receive results
- Channel information is available in app responses and contact channel_identities
- **Processing mode** (DISPATCH vs CONVERSATION) is set per app and affects message routing and contact/conversation auto-creation
- **Channel priority and fallback**: Use `channel_priority_order` to attempt channels in order with automatic fallback

