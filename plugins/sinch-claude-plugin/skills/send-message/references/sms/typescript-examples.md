# TypeScript / Node.js Examples

## Send SMS — Using @sinch/sdk-core

```typescript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID!,
  keyId: process.env.SINCH_KEY_ID!,
  keySecret: process.env.SINCH_KEY_SECRET!,
});

// Send a text SMS
const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID!,
    recipient: {
      identified_by: {
        channel_identities: [
          { channel: "SMS", identity: "+15551234567" },
        ],
      },
    },
    message: {
      text_message: { text: "Hello from Sinch!" },
    },
    channel_properties: {
      SMS_SENDER: "+15559876543",
    },
  },
});

console.log("Message sent:", response.message_id);
```

## Send SMS with Fallback — Using @sinch/sdk-core

```typescript
const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID!,
    channel_priority_order: ["WHATSAPP", "SMS"],
    recipient: {
      identified_by: {
        channel_identities: [
          { channel: "WHATSAPP", identity: "+15551234567" },
          { channel: "SMS", identity: "+15551234567" },
        ],
      },
    },
    message: {
      text_message: { text: "Your order has shipped!" },
    },
  },
});
```

## Send SMS with Helper — Using @sinch/sdk-core

```typescript
// Uses the sendTextMessage helper for a more concise call
const response = await sinch.conversation.messages.sendTextMessage({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID!,
    recipient: {
      identified_by: {
        channel_identities: [
          { channel: "SMS", identity: "+15551234567" },
        ],
      },
    },
    message: {
      text_message: { text: "Hello from Sinch!" },
    },
    channel_properties: {
      SMS_SENDER: "+15559876543",
    },
  },
});

console.log("Message sent:", response.message_id);
```

## List Messages — Using @sinch/sdk-core

```typescript
// List messages with PageResult (manual pagination)
const response = await sinch.conversation.messages.list({
  page_size: 20,
  channel: "SMS",
  conversation_id: "YOUR_CONVERSATION_ID",
});

console.log(response.data); // array of messages on the current page

// Iterate through all pages
while (response.hasNextPage) {
  const nextPage = await response.nextPage();
  console.log(nextPage.data);
}
```

## List Messages — AsyncIterator

```typescript
// Automatically iterates through all pages
for await (const message of sinch.conversation.messages.list({
  page_size: 20,
  channel: "SMS",
  conversation_id: "YOUR_CONVERSATION_ID",
})) {
  console.log(message);
}
```

## Send Template Message — Using @sinch/sdk-core

```typescript
const response = await sinch.conversation.messages.send({
  sendMessageRequestBody: {
    app_id: process.env.SINCH_APP_ID!,
    recipient: {
      identified_by: {
        channel_identities: [
          { channel: "SMS", identity: "+15551234567" },
        ],
      },
    },
    message: {
      template_message: {
        omni_template: {
          template_id: "YOUR_TEMPLATE_ID",
          version: "1",
          parameters: {
            name: { literal_parameter: { value: "John" } },
          },
        },
      },
    },
  },
});
```
