# RCS Location Message - JavaScript/Node.js Examples

## Overview

RCS location messages share geographic coordinates (latitude/longitude) with a title and optional label. When received, RCS transcodes them into an interactive button that opens the user's map app. Location messages are perfect for sharing store locations, meeting points, delivery addresses, or ride-sharing pickup points.

## Send RCS Location Message — Using Sinch Node.js SDK

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
      location_message: {
        title: "Our Store Location",
        label: "Visit us at 123 Main Street, Downtown",
        coordinates: {
          latitude: 40.7128,
          longitude: -74.006,
        },
      },
    },
  },
});

console.log("Location sent:", response.message_id);
```

## Send RCS Location — Using fetch (no SDK)

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

async function sendRcsLocation(to, title, label, latitude, longitude) {
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
      message: {
        location_message: {
          title,
          label,
          coordinates: {
            latitude,
            longitude,
          },
        },
      },
    }),
  });

  return res.json();
}

// Usage
const result = await sendRcsLocation(
  "+15551234567",
  "Meeting Point",
  "Meet me here at 3 PM",
  40.7128,
  -74.006,
);
console.log(result);
```

## Key Points

- **Title:** Short name for the location (e.g., "Our Store")
- **Label:** Additional context (e.g., "Visit us at 123 Main St")
- **Coordinates:** Latitude and longitude (decimal degrees)
- **Rendering:** RCS transcodes to text with a location choice button
- **User action:** Tapping opens map app with the coordinates
- **SMS fallback:** Sent as text with Google Maps URL
- **Use cases:** Store locations, meeting points, delivery addresses, ride-sharing pickup
- **Accuracy:** Use precise coordinates for best user experience
