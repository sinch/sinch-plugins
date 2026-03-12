# RCS Text Message - JavaScript/Node.js Examples

## Overview

RCS text messages are the simplest message type in RCS, supporting up to 3072 UTF-8 characters (including emojis). They deliver native read receipts and can be sent with SMS fallback for guaranteed delivery. Use the `curl` command below to send a quick test:

```bash
curl -X POST "https://us.conversation.api.sinch.com/v1/projects/YOUR_PROJECT_ID/messages:send" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "recipient": {
      "identified_by": {
        "channel_identities": [{"channel": "RCS", "identity": "+15551234567"}]
      }
    },
    "message": {"text_message": {"text": "Hello from RCS!"}}
  }'
```

## Send RCS Text Message — Using Sinch Node.js SDK

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID,
    recipient: {
      identified_by: {
        channel_identities: [
          {
            channel: "RCS",
            identity: "+15551234567",
          },
        ],
      },
    },
    message: {
      text_message: {
        text: "Hello from RCS! This is a simple text message.",
      },
    },
  },
});

console.log("Message sent:", response.message_id);
```

## Send RCS Text with SMS Fallback — Using Node.js SDK

```javascript
const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID,
    channel_priority_order: ["RCS", "SMS"],
    recipient: {
      identified_by: {
        channel_identities: [
          { channel: "RCS", identity: "+15551234567" },
          { channel: "SMS", identity: "+15551234567" },
        ],
      },
    },
    message: {
      text_message: {
        text: "Your order #12345 has shipped and will arrive by Friday!",
      },
    },
    channel_properties: {
      SMS_SENDER: "+15559876543",
    },
  },
});
```

## Send RCS Text — Using fetch (no SDK)

```javascript
async function getToken(keyId, keySecret) {
  const credentials = Buffer.from(`${keyId}:${keySecret}`).toString("base64");
  const res = await fetch("https://auth.sinch.com/oauth2/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${credentials}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });
  const data = await res.json();
  return data.access_token;
}

async function sendRcsText(to, text) {
  const token = await getToken(
    process.env.SINCH_KEY_ID,
    process.env.SINCH_KEY_SECRET,
  );

  const region = process.env.SINCH_REGION ?? "us";
  const projectId = process.env.SINCH_PROJECT_ID;
  const url = `https://${region}.conversation.api.sinch.com/v1/projects/${projectId}/messages:send`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      app_id: process.env.SINCH_APP_ID,
      recipient: {
        identified_by: {
          channel_identities: [{ channel: "RCS", identity: to }],
        },
      },
      message: { text_message: { text } },
    }),
  });

  return res.json();
}

// Usage
const result = await sendRcsText("+15551234567", "Hello from RCS!");
console.log(result);
```

## Key Points

- **Max length:** RCS text messages support up to 3072 characters
- **Encoding:** UTF-8 (supports all Unicode characters including emojis)
- **Delivery receipts:** Native support for delivered, read, and failed statuses
- **Typing indicators:** Can be sent separately using composing events
- **SMS fallback:** Always recommended for critical messages
- **Rich text:** Plain text only; use card/carousel messages for rich formatting
