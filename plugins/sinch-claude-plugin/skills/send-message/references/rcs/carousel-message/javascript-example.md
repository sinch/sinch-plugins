# RCS Carousel Message - JavaScript/Node.js Examples

## Overview

RCS carousel messages display 2-10 horizontally scrollable cards, each with its own title, description, media, and action buttons. Carousels are perfect for showcasing multiple products, services, or options in a single message. All cards maintain uniform height, and you can also include up to 3 "outer" action buttons displayed below the entire carousel.

## Send RCS Carousel Message — Using Sinch Node.js SDK

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
      carousel_message: {
        cards: [
          {
            title: "Product A",
            description:
              "High-quality product with amazing features. Only $29.99!",
            media_message: {
              url: "https://example.com/product-a.jpg",
            },
            choices: [
              {
                text_message: { text: "Buy Now" },
                postback_data: "buy_product_a",
              },
            ],
          },
          {
            title: "Product B",
            description: "Premium version with extended warranty. Just $39.99!",
            media_message: {
              url: "https://example.com/product-b.jpg",
            },
            choices: [
              {
                text_message: { text: "Buy Now" },
                postback_data: "buy_product_b",
              },
            ],
          },
          {
            title: "Product C",
            description:
              "Limited edition collector's item. Exclusive at $49.99!",
            media_message: {
              url: "https://example.com/product-c.jpg",
            },
            choices: [
              {
                text_message: { text: "Buy Now" },
                postback_data: "buy_product_c",
              },
            ],
          },
        ],
        choices: [
          {
            text_message: { text: "View All Products" },
            postback_data: "view_all",
          },
        ],
      },
    },
  },
});

console.log("Carousel sent:", response.message_id);
```

## Send RCS Carousel with Mixed Actions — Using Node.js SDK

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
      carousel_message: {
        cards: [
          {
            title: "Visit Our Store",
            description: "Find us at 123 Main St, Downtown",
            media_message: {
              url: "https://example.com/store-front.jpg",
            },
            choices: [
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
          {
            title: "Call Us",
            description: "Speak with our customer service team",
            media_message: {
              url: "https://example.com/customer-service.jpg",
            },
            choices: [
              {
                call_message: {
                  title: "Call Now",
                  phone_number: "+15559876543",
                },
              },
            ],
          },
          {
            title: "Shop Online",
            description: "Browse our full catalog on our website",
            media_message: {
              url: "https://example.com/website.jpg",
            },
            choices: [
              {
                url_message: {
                  title: "Visit Website",
                  url: "https://example.com/shop",
                },
              },
            ],
          },
        ],
      },
    },
  },
});
```

## Send RCS Carousel — Using fetch (no SDK)

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

async function sendRcsCarousel(to, cards, outerChoices = []) {
  const token = await getToken(
    process.env.SINCH_KEY_ID,
    process.env.SINCH_KEY_SECRET,
  );

  const region = process.env.SINCH_REGION ?? "us";
  const projectId = process.env.SINCH_PROJECT_ID;
  const url = `https://${region}.conversation.api.sinch.com/v1/projects/${projectId}/messages:send`;

  const formattedCards = cards.map((card) => ({
    title: card.title,
    description: card.description,
    media_message: { url: card.url },
    choices: card.choices.map((choice) => ({
      text_message: { text: choice },
      postback_data: choice.toLowerCase().replace(/ /g, "_"),
    })),
  }));

  const formattedOuterChoices = outerChoices.map((choice) => ({
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
        carousel_message: {
          cards: formattedCards,
          choices: formattedOuterChoices,
        },
      },
    }),
  });

  return res.json();
}

// Usage
const cards = [
  {
    title: "Product A",
    description: "Amazing features. $29.99",
    url: "https://example.com/product-a.jpg",
    choices: ["Buy Now"],
  },
  {
    title: "Product B",
    description: "Premium quality. $39.99",
    url: "https://example.com/product-b.jpg",
    choices: ["Buy Now"],
  },
];

const result = await sendRcsCarousel("+15551234567", cards, [
  "View All Products",
]);
console.log(result);
```

## Key Points

- **Card count:** 2-10 cards (1 card renders as standalone card message)
- **Card height:** Uniform across all cards; content may be truncated
- **Outer choices:** Max 3 choices displayed below the carousel
- **Per-card choices:** Each card can have its own action buttons
- **Media:** Same constraints as card messages (4:3 aspect ratio recommended)
- **Title/description:** Same limits as card messages (200/2000 chars)
- **SMS fallback:** Carousel degrades to multiple text blocks on SMS
- **Swipeable:** Native horizontal scrolling on RCS-enabled devices
- **Best practices:** Keep content concise to avoid truncation, test on devices
