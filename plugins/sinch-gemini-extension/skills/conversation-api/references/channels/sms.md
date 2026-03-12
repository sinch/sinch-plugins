# SMS Channel Reference

SMS is a core channel of the Sinch Conversation API. The API handles SMS-specific details like encoding detection and message concatenation automatically.

## Prerequisites

1. A service plan with at least one virtual number assigned.
2. A Conversation API app created in the same region as your service plan.

## SDK Reference

- [Node.js](https://developers.sinch.com/docs/conversation/sdk/node/syntax-reference)
- [Python](https://developers.sinch.com/docs/conversation/sdk/python/syntax-reference)
- [Java](https://developers.sinch.com/docs/conversation/sdk/java/syntax-reference)
- [.NET](https://developers.sinch.com/docs/conversation/sdk/dotnet/syntax-reference)

## Character Encoding

The API auto-detects encoding based on message characters:

| Encoding        | Max chars per SMS | Max chars per part (multipart) |
| --------------- | ----------------- | ------------------------------ |
| GSM 7-bit       | 160               | 153                            |
| UCS-2 (Unicode) | 70                | 67                             |

- GSM 7-bit covers standard Latin characters, digits, and common symbols.
- Any character outside GSM 7-bit (accented chars, CJK, emoji) triggers UCS-2, halving capacity.
- A single emoji forces the entire message to UCS-2.

### Auto Encoding

Reduces message parts by transliterating special characters (e.g., smart quotes to straight quotes). Emojis and CJK characters are not converted. Contact your Sinch account manager to enable.

## Concatenated Messages

When a message exceeds single-SMS limits, it is split into parts. Each part includes a UDH that reduces usable characters. Control max parts with `SMS_MAX_NUMBER_OF_MESSAGE_PARTS`.

## SMS Channel Properties

Set under `channel_properties` in your message request:

| Property                          | Description                                 |
| --------------------------------- | ------------------------------------------- |
| `SMS_SENDER`                      | Sender number or alphanumeric sender ID     |
| `SMS_MAX_NUMBER_OF_MESSAGE_PARTS` | Max concatenated parts allowed (integer)    |
| `SMS_FLASH_MESSAGE`               | Whether this is a flash SMS message         |

## Sender ID Types

| Type         | Description                | Example        |
| ------------ | -------------------------- | -------------- |
| Long code    | Standard phone number      | `+15551234567` |
| Short code   | 5-6 digit number           | `12345`        |
| Alphanumeric | Brand name (1-way only)    | `MyBrand`      |
| Toll-free    | Toll-free number           | `+18001234567` |
| 10DLC        | US registered local number | `+15551234567` |

## Opt-Out Handling

- Opt-out keywords (STOP, UNSUBSCRIBE, etc.) are processed by Sinch automatically for US/Canada numbers.
- Inbound opt-out messages are delivered via webhook as Mobile Originated (MO) messages.
- You must honor opt-outs and maintain your own suppression list for compliance.
- Re-opt-in typically requires the user to send a keyword like START.

## Send SMS Example

```json
{
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
      "text": "Hello from Sinch SMS!"
    }
  },
  "channel_properties": {
    "SMS_SENDER": "+15559876543"
  }
}
```

## SMS as Fallback Channel

```json
{
  "channel_priority_order": ["WHATSAPP", "SMS"],
  "recipient": {
    "identified_by": {
      "channel_identities": [
        { "channel": "WHATSAPP", "identity": "+15551234567" },
        { "channel": "SMS", "identity": "+15551234567" }
      ]
    }
  },
  "message": {
    "text_message": { "text": "Your order has shipped!" }
  }
}
```

## Inbound SMS (Webhook Payload)

Configure a webhook with `MESSAGE_INBOUND` trigger. See `references/webhooks/` for details.

```json
{
  "app_id": "YOUR_APP_ID",
  "message": {
    "contact_message": {
      "text_message": { "text": "STOP" }
    }
  },
  "channel_identity": {
    "channel": "SMS",
    "identity": "+15551234567"
  }
}
```

## Code Examples

- **TypeScript/Node.js**: [references/sms/typescript-examples.md](../sms/typescript-examples.md)
- **Python**: [references/sms/python-examples.md](../sms/python-examples.md)
- **Java**: [references/sms/java-examples.md](../sms/java-examples.md)

## SMS Gotchas

1. **Encoding surprises.** A single non-GSM character forces UCS-2 encoding, doubling message parts. Sanitize input or enable Auto Encoding.
2. **Sender ID rules vary by country.** Alphanumeric sender IDs are not supported in the US or Canada. Some countries require pre-registered sender IDs.
3. **10DLC registration is required.** US A2P messaging over local numbers requires 10DLC brand and campaign registration. Unregistered traffic will be filtered.
4. **Short code limitations.** US short codes require dedicated provisioning and carrier approval. Cannot send MMS via Conversation API.
5. **Concatenation costs.** Each SMS part is billed separately. A 161-character GSM message costs 2 SMS credits.
6. **Opt-out compliance.** US/Canada regulations (TCPA, CASL) require honoring opt-outs. Sinch handles standard keywords automatically.
7. **Delivery receipts are not guaranteed.** Some carriers do not return delivery receipts. Handle `UNKNOWN` status gracefully.

## Links

- [SMS Channel Overview](https://developers.sinch.com/docs/conversation/channel-support/sms.md)
- [SMS Setup Guide](https://developers.sinch.com/docs/conversation/channel-support/sms/set-up.md)
- [SMS Channel Properties](https://developers.sinch.com/docs/conversation/channel-support/sms/properties.md)
- [SMS Message Support](https://developers.sinch.com/docs/conversation/channel-support/sms/message-support.md)
- [Character Encoding](https://developers.sinch.com/docs/sms/resources/message-info/character-support.md)
- [Auto Encoding](https://developers.sinch.com/docs/sms/resources/message-info/auto-encoding.md)
