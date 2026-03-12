# RCS Channel Reference

RCS (Rich Communication Services) enables rich, branded messaging in the native device messaging app — including rich cards, carousels, suggested actions, media messages, location messages, read receipts, and typing indicators. When a device does not support RCS, configure automatic fallback to SMS.

## Prerequisites

1. A provisioned RCS Sender Agent (request via Sinch — requires carrier approval).
2. A Conversation API app in the same region as your RCS Agent.
3. At least one webhook configured for delivery reports and inbound messages.

## SDK Reference

- [Node.js](https://developers.sinch.com/docs/conversation/sdk/node/syntax-reference)
- [Python](https://developers.sinch.com/docs/conversation/sdk/python/syntax-reference)
- [Java](https://developers.sinch.com/docs/conversation/sdk/java/syntax-reference)
- [.NET](https://developers.sinch.com/docs/conversation/sdk/dotnet/syntax-reference)

## RCS Agents

An RCS Agent is your business identity on RCS — includes brand name, logo, description, and verification status. Agents must be approved by carriers before use. Provisioning is handled through Sinch.

## Message Types

| Message Type | When to Use                     | Key Indicators in User Prompt                                    |
| ------------ | ------------------------------- | ---------------------------------------------------------------- |
| **Text**     | Simple text messages            | "send a message", no special formatting                          |
| **Media**    | Images, videos, PDFs            | "send an image", "share a photo", file/media URLs                |
| **Choice**   | Interactive buttons/suggestions | "with options", "with buttons", "choose between"                 |
| **Card**     | Rich card with image + buttons  | "rich card", "card with image", "product card"                   |
| **Carousel** | Multiple swipeable cards        | "carousel", "swipeable cards", "multiple products"               |
| **Location** | Share coordinates/map           | "send location", "share coordinates", "map"                     |
| **Template** | Pre-defined reusable messages   | "use template", "send template"                                  |

**Detection logic:** Check for structural keywords (carousel, card, buttons) → media indicators → location indicators → default to text.

## Rich Cards

```json
{
  "message": {
    "card_message": {
      "title": "Summer Sale",
      "description": "50% off all items this weekend!",
      "media_message": { "url": "https://example.com/sale.jpg" },
      "choices": [
        { "text_message": { "text": "Shop Now" }, "postback_data": "shop" },
        { "text_message": { "text": "Learn More" }, "postback_data": "learn" }
      ]
    }
  }
}
```

Limits: title max 200 chars, description max 2000 chars.

## Carousels

2-10 swipeable cards. 1 card renders standalone. Up to 3 outer choices below.

```json
{
  "message": {
    "carousel_message": {
      "cards": [
        {
          "title": "Product A", "description": "$29.99",
          "media_message": { "url": "https://example.com/a.jpg" },
          "choices": [{ "text_message": { "text": "Buy" }, "postback_data": "buy_a" }]
        },
        {
          "title": "Product B", "description": "$39.99",
          "media_message": { "url": "https://example.com/b.jpg" },
          "choices": [{ "text_message": { "text": "Buy" }, "postback_data": "buy_b" }]
        }
      ],
      "choices": [{ "text_message": { "text": "View All" }, "postback_data": "all" }]
    }
  }
}
```

## Choice Messages

Interactive suggestions as chips: suggested replies and suggested actions (open URL, dial, show location, share location, create calendar event).

```json
{
  "message": {
    "choice_message": {
      "text_message": { "text": "How would you like to proceed?" },
      "choices": [
        { "text_message": { "text": "Call Us" }, "postback_data": "call" },
        { "text_message": { "text": "Visit Website" }, "postback_data": "website" }
      ]
    }
  }
}
```

## Media Messages

Images, videos, audio, PDFs. Up to 100 MB. Formats: JPEG, PNG, MP4, GIF, PDF. Auto-detected from URL.

## Location Messages

```json
{
  "message": {
    "location_message": {
      "title": "Your ride is here!",
      "label": "Meet your driver at the specified address.",
      "coordinates": { "latitude": 55.610479, "longitude": 13.002873 }
    }
  }
}
```

Transcoded to text with a location choice button on RCS.

## Channel-Specific Properties

| Property                              | Description                                           |
| ------------------------------------- | ----------------------------------------------------- |
| `RCS_WEBVIEW_MODE`                    | Size of webview for OpenUrl actions                   |
| `RCS_CARD_ORIENTATION`                | Orientation of rich card                              |
| `RCS_CARD_THUMBNAIL_IMAGE_ALIGNMENT`  | Image preview alignment in rich card                  |

## Capability Check

Check if a device supports RCS before sending:

```bash
curl -X POST "https://us.conversation.api.sinch.com/v1/projects/$PROJECT_ID/capability:query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "recipient": {
      "identified_by": {
        "channel_identities": [{ "channel": "RCS", "identity": "+15551234567" }]
      }
    }
  }'
```

Result delivered via webhook `CAPABILITY` trigger.

## Channel Fallback (RCS to SMS)

```json
{
  "channel_priority_order": ["RCS", "SMS"],
  "recipient": {
    "identified_by": {
      "channel_identities": [
        { "channel": "RCS", "identity": "+15551234567" },
        { "channel": "SMS", "identity": "+15551234567" }
      ]
    }
  },
  "message": { "text_message": { "text": "Your order shipped!" } },
  "channel_properties": { "SMS_SENDER": "+15559876543" }
}
```

Fallback triggers `SWITCH_ON_CHANNEL` delivery report.

## Typing Indicators

```json
{
  "app_id": "YOUR_APP_ID",
  "recipient": {
    "identified_by": {
      "channel_identities": [{ "channel": "RCS", "identity": "+15551234567" }]
    }
  },
  "event": { "composing_event": {} }
}
```

## Code Examples (by message type)

- **Text**: [references/rcs/text-message/](../rcs/text-message/) (javascript, python, java)
- **Card**: [references/rcs/card-message/](../rcs/card-message/)
- **Carousel**: [references/rcs/carousel-message/](../rcs/carousel-message/)
- **Choice**: [references/rcs/choice-message/](../rcs/choice-message/)
- **Media**: [references/rcs/media-message/](../rcs/media-message/)
- **Location**: [references/rcs/location-message/](../rcs/location-message/)
- **List Messages**: [references/rcs/list-messages/](../rcs/list-messages/)
- **Template**: [references/rcs/template-message/](../rcs/template-message/)

## RCS Gotchas

1. **Carrier and device support varies.** RCS is not universally available. Always configure SMS fallback.
2. **Agent provisioning takes time.** Carrier review can take days or weeks.
3. **Media dimensions matter.** Rich card media must fit predefined heights. Use 4:3 (960x720) for best results.
4. **Carousel truncation.** Cards share uniform height. Long content is truncated.
5. **No template system.** Unlike WhatsApp, RCS does not require pre-approved templates.
6. **Read receipts are native.** RCS provides read receipts automatically.
7. **Rich messages degrade on non-RCS.** Carousels sent via SMS fallback become plain text. Test fallback rendering.
8. **Media caching.** URLs cached up to 28 days. Rename files to force refresh.

## Links

- [RCS Channel Overview](https://developers.sinch.com/docs/conversation/channel-support/rcs)
- [RCS Setup Guide](https://developers.sinch.com/docs/conversation/channel-support/rcs/set-up)
- [RCS Message Support](https://developers.sinch.com/docs/conversation/channel-support/rcs/message-support)
- [RCS Message Types](https://developers.sinch.com/docs/conversation/message-types)
