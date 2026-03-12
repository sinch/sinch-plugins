# RCS Media Message - JavaScript/Node.js Examples

## Overview

RCS media messages send standalone images, videos, or audio files without additional text or buttons (use card messages for that). Media files must be publicly accessible via HTTPS URLs. Videos can include optional thumbnail images for preview. Use the `curl` command below to send a quick test:

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
    "message": {"media_message": {"url": "https://example.com/image.jpg"}}
  }'
```

## Send RCS Media Message (Image) — Using Sinch Node.js SDK

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
      media_message: {
        url: "https://example.com/image.jpg",
      },
    },
  },
});

console.log("Media sent:", response.message_id);
```

## Send RCS Media with Thumbnail — Using Node.js SDK

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
      media_message: {
        url: "https://example.com/video.mp4",
        thumbnail_url: "https://example.com/video-thumb.jpg",
      },
    },
  },
});
```

## Send RCS Media — Using fetch (no SDK)

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

async function sendRcsMedia(to, mediaUrl, thumbnailUrl = null) {
  const token = await getToken(
    process.env.SINCH_KEY_ID,
    process.env.SINCH_KEY_SECRET,
  );

  const region = process.env.SINCH_REGION ?? "us";
  const projectId = process.env.SINCH_PROJECT_ID;
  const url = `https://${region}.conversation.api.sinch.com/v1/projects/${projectId}/messages:send`;

  const mediaMessage = { url: mediaUrl };
  if (thumbnailUrl) {
    mediaMessage.thumbnail_url = thumbnailUrl;
  }

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
        media_message: mediaMessage,
      },
    }),
  });

  return res.json();
}

// Usage
const result = await sendRcsMedia(
  "+15551234567",
  "https://example.com/photo.jpg",
);
console.log(result);
```

## Key Points

- **Media types:** Images (JPG, PNG, GIF), videos (MP4), audio (MP3, AAC)
- **File size:** Max 10MB for images, 100MB for videos
- **URL requirement:** Must be HTTPS and publicly accessible
- **Thumbnail:** Optional for videos; enhances preview experience
- **Caching:** Media URLs are cached for 28 days by carriers
- **SMS fallback:** Media sent as URL link in text message
- **Use cards:** For media with text/buttons, use card or carousel messages
