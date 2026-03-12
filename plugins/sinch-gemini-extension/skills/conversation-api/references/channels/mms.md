# MMS Channel Reference

MMS (Multimedia Messaging Service) extends SMS with support for images, video, audio, PDFs and other media. Available in the **United States, Canada, and Australia** only.

## Prerequisites

1. A service plan with an MMS-capable number (US/CA/AU long code or toll-free).
2. A Conversation API app in the same region as your service plan.
3. MMS channel setup requires: Account ID, API key, default originator or short code, username and password.

## SDK Reference

- [Node.js](https://developers.sinch.com/docs/conversation/sdk/node/syntax-reference)
- [Python](https://developers.sinch.com/docs/conversation/sdk/python/syntax-reference)
- [Java](https://developers.sinch.com/docs/conversation/sdk/java/syntax-reference)
- [.NET](https://developers.sinch.com/docs/conversation/sdk/dotnet/syntax-reference)

## Supported Media Types

| Media Type | Common Formats      | Notes                               |
|------------|---------------------|-------------------------------------|
| Image      | JPEG, PNG, GIF, BMP | Most widely supported               |
| Video      | MP4, 3GPP           | Quality may be reduced for delivery |
| Audio      | MP3, WAV, AMR       | Limited carrier support             |
| vCard      | VCF                 | Contact cards                       |
| Text       | Plain text          | Included as message body            |
| PDF        | PDF                 | Included as URL                     |

All media files must serve a valid `Content-Type` header. `application/octet-stream` may be rejected.

## File Size Limits

Keep media **under 1 MB** for reliable delivery.

| Number Type | Typical Max | Notes                           |
|-------------|-------------|----------------------------------|
| Long code   | ~1 MB       | Varies by carrier                |
| Toll-free   | ~1 MB       | Varies by carrier                |
| Short code  | Varies      | Transcoding not supported        |
| 10DLC       | Varies      | Transcoding not supported        |

The API accepts up to 100 MB, but carriers impose lower limits. Base64 encoding adds ~37% size overhead.

## MMS Channel Properties

| Property               | Description                                              |
|------------------------|----------------------------------------------------------|
| `MMS_SENDER`           | Sender phone number                                      |
| `MMS_STRICT_VALIDATION`| Validate media against best practices (default: false)   |

## Card Messages via MMS

Card `title` becomes the MMS Subject line (max 80 chars, 40 recommended). Title is not duplicated in body.

```json
{
  "message": {
    "card_message": {
      "title": "Your Order Has Shipped",
      "description": "Track your delivery at the link below.",
      "media_message": { "url": "https://example.com/shipping.jpg" }
    }
  }
}
```

## Unsupported Message Types (Transcoded to Text)

- Choice messages (buttons/quick replies)
- Carousel messages
- Location messages

## Send MMS Image

```json
{
  "app_id": "YOUR_APP_ID",
  "recipient": {
    "identified_by": {
      "channel_identities": [{
        "channel": "MMS",
        "identity": "+15551234567"
      }]
    }
  },
  "message": {
    "media_message": { "url": "https://example.com/product-photo.jpg" }
  },
  "channel_properties": { "MMS_SENDER": "+15559876543" }
}
```

## MMS with SMS Fallback

```json
{
  "channel_priority_order": ["MMS", "SMS"],
  "recipient": {
    "identified_by": {
      "channel_identities": [
        { "channel": "MMS", "identity": "+15551234567" },
        { "channel": "SMS", "identity": "+15551234567" }
      ]
    }
  },
  "message": {
    "media_message": { "url": "https://example.com/coupon.jpg" }
  },
  "channel_properties": {
    "MMS_SENDER": "+15559876543",
    "SMS_SENDER": "+15559876543"
  }
}
```

## MMS Gotchas

1. **US, Canada, and Australia only.** Use WhatsApp, RCS, or SMS for international media messaging.
2. **Keep files under 1 MB.** Carrier limits are ~1 MB. Oversized media is compressed or rejected.
3. **Base64 overhead.** Binary content encoded with Base64 produces files ~37% larger.
4. **Content-Type headers required.** Media URLs must return valid MIME types. Generic `application/octet-stream` may be rejected.
5. **Media URLs must be publicly accessible.** URLs behind auth or firewalls fail.
6. **Short code/10DLC MMS limitations.** Transcoding not supported. Size limits vary by operator.
7. **Video quality reduction.** Video may be compressed significantly. For high-quality video, send a link via SMS.
8. **Rich messages degrade.** Carousels, choices, and location are transcoded to plain text.
9. **No read receipts.** MMS does not provide read receipts. Some carriers return delivery confirmations.

## Links

- [MMS Channel Overview](https://developers.sinch.com/docs/conversation/channel-support/mms.md)
- [MMS Setup Guide](https://developers.sinch.com/docs/conversation/channel-support/mms/set-up)
- [MMS Message Support](https://developers.sinch.com/docs/conversation/channel-support/mms/message-support)
- [Media Message Type](https://developers.sinch.com/docs/conversation/message-types/media-message.md)
