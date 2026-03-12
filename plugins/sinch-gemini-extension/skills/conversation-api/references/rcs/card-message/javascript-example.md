# RCS Card Message - JavaScript/Node.js Examples

## Overview

RCS card messages are rich media messages that combine a title, description, image or video, and interactive buttons. They're ideal for showcasing products, promotions, or any content that benefits from visual presentation. Cards support up to 200 characters for the title and 2000 characters for the description, with a recommended 4:3 aspect ratio for media.

## Send RCS Card Message — Using Sinch Node.js SDK

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
      card_message: {
        title: "Summer Sale!",
        description:
          "50% off all items this weekend only. Don't miss out on amazing deals!",
        media_message: {
          url: "https://example.com/summer-sale.jpg",
        },
        choices: [
          {
            text_message: { text: "Shop Now" },
            postback_data: "shop_summer_sale",
          },
          {
            text_message: { text: "Learn More" },
            postback_data: "learn_more",
          },
        ],
      },
    },
  },
});

console.log("Card sent:", response.message_id);
```

## Send RCS Card with URL Action — Using Node.js SDK

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
      card_message: {
        title: "New Product Launch",
        description: "Check out our latest innovation! Available now.",
        media_message: {
          url: "https://example.com/product-image.jpg",
        },
        choices: [
          {
            url_message: {
              title: "View Product",
              url: "https://example.com/products/new-launch",
            },
          },
          {
            call_message: {
              title: "Call Sales",
              phone_number: "+15559876543",
            },
          },
        ],
      },
    },
  },
});
```

## Send RCS Card — Using fetch (no SDK)

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

async function sendRcsCard(to, title, description, imageUrl, choices) {
  const token = await getToken(
    process.env.SINCH_KEY_ID,
    process.env.SINCH_KEY_SECRET,
  );

  const region = process.env.SINCH_REGION ?? "us";
  const projectId = process.env.SINCH_PROJECT_ID;
  const url = `https://${region}.conversation.api.sinch.com/v1/projects/${projectId}/messages:send`;

  const choicesArray = choices.map((choice) => ({
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
        card_message: {
          title,
          description,
          media_message: { url: imageUrl },
          choices: choicesArray,
        },
      },
    }),
  });

  return res.json();
}

// Usage
const result = await sendRcsCard(
  "+15551234567",
  "Special Offer",
  "Limited time: Buy one get one free!",
  "https://example.com/offer.jpg",
  ["Shop Now", "Learn More"],
);
console.log(result);
```

## Key Points

- **Title:** Max 200 characters (special chars/emojis may count as 2+)
- **Description:** Max 2000 characters
- **Media:** Images or videos; recommended aspect ratio 4:3 (960x720)
- **Choices:** Interactive buttons (text, URL, call, location actions)
- **Postback data:** Identifier sent to your webhook when user taps a button
- **Orientation:** Use `RCS_CARD_ORIENTATION` channel property for horizontal/vertical layout
- **Thumbnail alignment:** Use `RCS_CARD_THUMBNAIL_IMAGE_ALIGNMENT` for image positioning
- **SMS fallback:** Card degrades to text + media link on SMS
- **Media caching:** URLs cached for 28 days; rename file to force refresh
