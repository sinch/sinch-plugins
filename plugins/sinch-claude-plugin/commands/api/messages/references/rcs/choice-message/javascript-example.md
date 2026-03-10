# RCS Choice Message - JavaScript/Node.js Examples

## Overview

RCS choice messages display a text prompt with interactive buttons (chips) that users can tap to respond. Choice buttons support various action types including text replies, URL opening, phone dialing, location sharing, and calendar events. Choices are rendered as chips below the message, providing a cleaner and faster user experience than typing.

## Send RCS Choice Message — Using Sinch Node.js SDK

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
      choice_message: {
        text_message: {
          text: "How can we help you today?",
        },
        choices: [
          {
            text_message: { text: "Track Order" },
            postback_data: "track_order",
          },
          {
            text_message: { text: "Contact Support" },
            postback_data: "contact_support",
          },
          {
            text_message: { text: "Browse Products" },
            postback_data: "browse_products",
          },
        ],
      },
    },
  },
});

console.log("Choice message sent:", response.message_id);
```

## Send RCS Choice with URL and Call Actions — Using Node.js SDK

```javascript
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
      choice_message: {
        text_message: {
          text: "Need assistance? Choose an option:",
        },
        choices: [
          {
            call_message: {
              title: "Call Us",
              phone_number: "+15559876543",
            },
          },
          {
            url_message: {
              title: "Visit Website",
              url: "https://example.com/support",
            },
          },
          {
            location_message: {
              title: "Get Directions",
              coordinates: {
                latitude: 40.7128,
                longitude: -74.006,
              },
            },
          },
        ],
      },
    },
  },
});
```

## Send RCS Choice — Using fetch (no SDK)

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

async function sendRcsChoice(to, text, choices) {
  const token = await getToken(
    process.env.SINCH_KEY_ID,
    process.env.SINCH_KEY_SECRET,
  );

  const region = process.env.SINCH_REGION ?? "us";
  const projectId = process.env.SINCH_PROJECT_ID;
  const url = `https://${region}.conversation.api.sinch.com/v1/projects/${projectId}/messages:send`;

  const formattedChoices = choices.map((choice) => ({
    text_message: { text: choice },
    postback_data: choice.toLowerCase().replace(/ /g, "_"),
  }));

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
      message: {
        choice_message: {
          text_message: { text },
          choices: formattedChoices,
        },
      },
    }),
  });

  return res.json();
}

// Usage
const result = await sendRcsChoice(
  "+15551234567",
  "Choose your preferred contact method:",
  ["Call Us", "Email Us", "Live Chat"],
);
console.log(result);
```

## Key Points

- **Choice types:** Text, URL, Call, Location, Calendar, Request Location
- **Appearance:** Rendered as chips/buttons below the message
- **Postback data:** Sent to webhook when user taps a choice
- **URL actions:** Opens link in browser or in-app webview
- **Call actions:** Triggers phone dialer with pre-filled number
- **Location actions:** Opens map app with coordinates
- **Webview mode:** Use `RCS_WEBVIEW_MODE` property (TALL, HALF, FULL)
- **SMS fallback:** Choices degrade to numbered list in text message
- **User experience:** Easier for users than typing; faster response times
