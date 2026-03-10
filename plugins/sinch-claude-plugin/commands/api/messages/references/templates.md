# Template Management API Reference

Manages **omni-channel templates** — pre-defined message formats with dynamic parameters, multiple languages, and channel-specific overrides (e.g., WhatsApp-approved templates).

**Use V2 exclusively** — V1 reached end-of-life on January 31, 2026.

## SDK Reference

- [Node.js](https://developers.sinch.com/docs/conversation/sdk/node/syntax-reference)
- [Python](https://developers.sinch.com/docs/conversation/sdk/python/syntax-reference)
- [Java](https://developers.sinch.com/docs/conversation/sdk/java/syntax-reference)
- [.NET](https://developers.sinch.com/docs/conversation/sdk/dotnet/syntax-reference)

## When to Use

- Creating, updating, listing, or deleting omni-channel message templates
- Setting up multi-language template translations
- Configuring channel-specific template overrides (e.g., WhatsApp template references)

## Base URLs (Separate from Conversation API)

Templates use a separate base URL (`template.api.sinch.com`). Region-locked — templates can only be used by apps in the same region.

| Region | Base URL                             |
|--------|--------------------------------------|
| US     | `https://us.template.api.sinch.com`  |
| EU     | `https://eu.template.api.sinch.com`  |
| BR     | `https://br.template.api.sinch.com`  |

## API Endpoints (V2)

All endpoints prefixed with `/v2/projects/{project_id}`.

| Method | Path                                       | Description                |
|--------|--------------------------------------------|----------------------------|
| GET    | `/templates`                               | List all templates         |
| POST   | `/templates`                               | Create a template          |
| GET    | `/templates/{template_id}`                 | Get a template             |
| PUT    | `/templates/{template_id}`                 | Update (include `version`) |
| DELETE | `/templates/{template_id}`                 | Delete a template          |
| GET    | `/templates/{template_id}/translations`    | List translations          |

## Key Concepts

| Concept                      | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| Omni-channel template        | Uses Conversation API generic message format. Works across all channels.    |
| Channel-specific template    | Stored by the channel itself (e.g., WhatsApp-approved). Referenced, not managed here. |
| Translation                  | Language-specific version keyed by BCP-47 code (e.g., `en-US`, `fr`).      |
| Variable                     | Dynamic placeholder (`${name}`). Defined with `key` and `preview_value`.   |
| Channel template override    | Per-channel override replacing omni-channel template for that channel.     |

## Template Structure

```json
{
  "id": "01F8MECHZX3TBDSZ7XRADM79XE",
  "description": "Order confirmation template",
  "version": 1,
  "default_translation": "en-US",
  "translations": [
    {
      "language_code": "en-US",
      "version": "1",
      "variables": [
        { "key": "customer_name", "preview_value": "Jane Doe" },
        { "key": "order_number", "preview_value": "ORD-12345" }
      ],
      "text_message": {
        "text": "Hi ${customer_name}, your order ${order_number} has been confirmed!"
      }
    }
  ]
}
```

## Creating Templates

### Simple Text Template

```bash
curl -X POST "https://us.template.api.sinch.com/v2/projects/$PROJECT_ID/templates" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "description": "Welcome message",
    "default_translation": "en-US",
    "translations": [{
      "language_code": "en-US",
      "version": "1",
      "variables": [{ "key": "name", "preview_value": "John" }],
      "text_message": { "text": "Welcome ${name}!" }
    }]
  }'
```

### With WhatsApp Channel Override

Use a generic omni-channel template but override with an approved WhatsApp template:

```json
{
  "description": "Order shipped with WhatsApp override",
  "default_translation": "en-US",
  "translations": [{
    "language_code": "en-US",
    "version": "1",
    "variables": [{ "key": "tracking_number", "preview_value": "TRK123" }],
    "channel_template_overrides": {
      "WHATSAPP": {
        "template_reference": {
          "template_id": "shipping_notification_approved",
          "version": "1",
          "language_code": "en-US",
          "parameters": { "body[1]text": "Default value" }
        },
        "parameter_mappings": { "body[1]text": "tracking_number" }
      }
    },
    "text_message": { "text": "Shipped! Tracking: ${tracking_number}" }
  }]
}
```

On WhatsApp: uses the approved channel-specific template. On all other channels: uses the generic `text_message`.

### With Multiple Languages

```json
{
  "default_translation": "en-US",
  "translations": [
    {
      "language_code": "en-US", "version": "1",
      "variables": [{ "key": "name", "preview_value": "Jane" }],
      "text_message": { "text": "Hi ${name}, your appointment is confirmed." }
    },
    {
      "language_code": "es", "version": "1",
      "variables": [{ "key": "name", "preview_value": "María" }],
      "text_message": { "text": "Hola ${name}, tu cita está confirmada." }
    }
  ]
}
```

## Updating Templates

Include current `version` (optimistic concurrency). PUT fully replaces the template.

```bash
curl -X PUT "https://us.template.api.sinch.com/v2/projects/$PROJECT_ID/templates/$TEMPLATE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{ "version": 1, "description": "Updated", "default_translation": "en-US", "translations": [...] }'
```

## Translation Message Types

Each translation supports one of: `text_message`, `card_message`, `carousel_message`, `choice_message`, `location_message`, `media_message`, `template_message`, `list_message`.

Plus: `channel_template_overrides`, `variables`, `language_code`, `version`.

## Channel-Specific Templates (NOT Managed Here)

| Channel   | Template Type              | Management                                    |
|-----------|----------------------------|-----------------------------------------------|
| WhatsApp  | WhatsApp Message Templates | Created via Dashboard/Provisioning API, approved by Meta |
| KakaoTalk | AlimTalk Templates         | Registered by Sinch, approved by KakaoTalk    |
| WeChat    | WeChat Templates           | Pre-defined by WeChat, added via admin portal |

Reference these via `channel_template_overrides`, but cannot create/modify them here.

## Common Pitfalls

1. **V1 is past EOL.** Use V2 (`/v2/projects/...`) exclusively.
2. **Region locking.** Templates created in US can only be used by US apps.
3. **Version conflicts on update.** Must pass current `version`. Concurrent updates fail.
4. **Omni-channel vs channel-specific confusion.** This API manages omni-channel templates. WhatsApp templates (Meta-approved) are separate.
5. **WhatsApp requires approved templates outside service window.** Use omni-channel template with WhatsApp override.
6. **Variable key format.** Use `${key_name}` syntax. Key must match `variables` array.
7. **Parameter mapping for overrides.** `parameter_mappings` maps channel-specific keys to omni-channel variable keys.

## Links

- [Managing Templates](https://developers.sinch.com/docs/conversation/templates)
- [Template API Overview](https://developers.sinch.com/docs/conversation/api-reference/template/overview)
- [Templates V2 API](https://developers.sinch.com/docs/conversation/api-reference/template/templates-v2)
- [WhatsApp Template Messages](https://developers.sinch.com/docs/conversation/channel-support/whatsapp/template-support)
- [Sinch Dashboard Message Composer](https://dashboard.sinch.com/convapi/message-composer)
