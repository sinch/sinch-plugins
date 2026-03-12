# List RCS Messages - JavaScript Examples

## Overview

Retrieve message history from RCS conversations using the Sinch Conversation API. The list messages endpoint supports filtering by contact, conversation, channel, time range, and pagination.

**Key Parameters:**

- `app_id` - Your Conversation API app ID (required)
- `channel` - Filter by channel (e.g., "RCS")
- `contact_id` - Filter by specific contact
- `conversation_id` - Filter by specific conversation
- `page_size` - Number of messages per page (default: 10, max: 1000)
- `page_token` - Token for next page in pagination
- `start_time` - Filter messages after this time (ISO 8601)
- `end_time` - Filter messages before this time (ISO 8601)

**Authentication:** OAuth2 Bearer token or Basic Auth with `btoa(keyId:keySecret)`

## Using Sinch Node.js SDK

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

// List recent RCS messages
const response = await sinch.conversation.messages.list({
  app_id: process.env.SINCH_APP_ID,
  channel: "RCS",
  page_size: 20,
});

console.log(`Found ${response.messages.length} messages`);
response.messages.forEach((msg) => {
  console.log(`${msg.id}: ${msg.direction} at ${msg.accept_time}`);
});

// Pagination
if (response.next_page_token) {
  const nextPage = await sinch.conversation.messages.list({
    app_id: process.env.SINCH_APP_ID,
    page_token: response.next_page_token,
  });
}
```

## List Messages for Specific Contact

```javascript
const response = await sinch.conversation.messages.list({
  app_id: process.env.SINCH_APP_ID,
  contact_id: "01GXXX...", // Contact ID
  channel: "RCS",
  page_size: 50,
});
```

## List Messages with Time Filter

```javascript
const response = await sinch.conversation.messages.list({
  app_id: process.env.SINCH_APP_ID,
  channel: "RCS",
  start_time: "2024-01-01T00:00:00Z",
  end_time: "2024-12-31T23:59:59Z",
  page_size: 100,
});
```

## Using fetch with OAuth2 (no SDK)

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

async function listRcsMessages(pageSize = 10) {
  const token = await getToken(
    process.env.SINCH_KEY_ID,
    process.env.SINCH_KEY_SECRET,
  );

  const region = process.env.SINCH_REGION ?? "us";
  const projectId = process.env.SINCH_PROJECT_ID;
  const appId = process.env.SINCH_APP_ID;

  const params = new URLSearchParams({
    app_id: appId,
    channel: "RCS",
    page_size: pageSize.toString(),
  });

  const url = `https://${region}.conversation.api.sinch.com/v1/projects/${projectId}/messages?${params}`;

  const res = await fetch(url, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return res.json();
}

// Usage
const result = await listRcsMessages(20);
console.log(result);
```

## Using fetch with Basic Auth (no SDK, no OAuth)

```javascript
async function listRcsMessagesBasicAuth(pageSize = 10) {
  const keyId = process.env.SINCH_KEY_ID;
  const keySecret = process.env.SINCH_KEY_SECRET;
  const credentials = Buffer.from(`${keyId}:${keySecret}`).toString("base64");

  const region = process.env.SINCH_REGION ?? "us";
  const projectId = process.env.SINCH_PROJECT_ID;
  const appId = process.env.SINCH_APP_ID;

  const params = new URLSearchParams({
    app_id: appId,
    channel: "RCS",
    page_size: pageSize.toString(),
  });

  const url = `https://${region}.conversation.api.sinch.com/v1/projects/${projectId}/messages?${params}`;

  const res = await fetch(url, {
    method: "GET",
    headers: {
      Authorization: `Basic ${credentials}`,
    },
  });

  return res.json();
}

// Usage
const result = await listRcsMessagesBasicAuth(20);
console.log(result);
```

## Key Points

- **Default sort:** Messages returned in descending order by `accept_time` (most recent first)
- **Pagination:** Use `next_page_token` from response to fetch next page
- **Max page size:** 1000 messages per request
- **Time filters:** Use ISO 8601 format for `start_time` and `end_time`
- **Channel filter:** "RCS" to get only RCS messages
- **Contact filter:** Requires valid contact ID from Conversation API
- **Authentication:** Supports both OAuth2 Bearer tokens and Basic Auth
- **Message details:** Each message includes ID, direction, channel, content, timestamps, status
