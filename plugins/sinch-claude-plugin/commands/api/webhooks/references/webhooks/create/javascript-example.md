# Create Webhook - JavaScript Example

## Using @sinch/sdk-core

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

async function createWebhook() {
  try {
    const webhook = await sinch.conversation.webhooks.create({
      createWebhookRequestBody: {
        app_id: "YOUR_APP_ID",
        target: "https://your-server.com/webhook",
        target_type: "HTTP",
        triggers: ["MESSAGE_INBOUND", "MESSAGE_DELIVERY", "EVENT_INBOUND"],
        secret: "your-webhook-secret-for-hmac", // Optional: for HMAC signature
        // Optional: OAuth2.0 configuration for webhook callbacks
        client_credentials: {
          client_id: "your-oauth-client-id",
          client_secret: "your-oauth-client-secret",
          endpoint: "https://your-server.com/oauth2/token",
          scope: "webhooks",
          token_request_type: "BASIC", // or 'FORM'
        },
      },
    });

    console.log("Webhook created:", webhook);
    console.log("Webhook ID:", webhook.id);

    return webhook;
  } catch (error) {
    console.error("Failed to create webhook:", error);
    throw error;
  }
}

createWebhook();
```

## Raw HTTP with OAuth2.0

```javascript
const https = require("https");
const querystring = require("querystring");

// Step 1: Get access token
function getAccessToken(keyId, keySecret) {
  return new Promise((resolve, reject) => {
    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");
    const postData = querystring.stringify({
      grant_type: "client_credentials",
    });

    const options = {
      hostname: "auth.sinch.com",
      path: "/oauth2/token",
      method: "POST",
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/x-www-form-urlencoded",
        "Content-Length": postData.length,
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(data).access_token);
        } else {
          reject(new Error(`Auth failed: ${res.statusCode} ${data}`));
        }
      });
    });

    req.on("error", reject);
    req.write(postData);
    req.end();
  });
}

// Step 2: Create webhook
async function createWebhook(projectId, accessToken, webhookData) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";
    const payload = JSON.stringify(webhookData);

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks`,
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(payload),
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(data));
        } else {
          reject(new Error(`Create webhook failed: ${res.statusCode} ${data}`));
        }
      });
    });

    req.on("error", reject);
    req.write(payload);
    req.end();
  });
}

// Usage
(async () => {
  try {
    const token = await getAccessToken(
      process.env.SINCH_KEY_ID,
      process.env.SINCH_KEY_SECRET,
    );

    const webhook = await createWebhook(process.env.SINCH_PROJECT_ID, token, {
      app_id: "YOUR_APP_ID",
      target: "https://your-server.com/webhook",
      target_type: "HTTP",
      triggers: ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
      secret: "your-webhook-secret",
    });

    console.log("Webhook created:", webhook);
  } catch (error) {
    console.error("Error:", error.message);
  }
})();
```

## Raw HTTP with Basic Auth (Testing Only)

```javascript
const https = require("https");

function createWebhook(projectId, keyId, keySecret, webhookData) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";
    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");
    const payload = JSON.stringify(webhookData);

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks`,
      method: "POST",
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(payload),
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(data));
        } else {
          reject(new Error(`Failed: ${res.statusCode} ${data}`));
        }
      });
    });

    req.on("error", reject);
    req.write(payload);
    req.end();
  });
}

// Usage
createWebhook(
  process.env.SINCH_PROJECT_ID,
  process.env.SINCH_KEY_ID,
  process.env.SINCH_KEY_SECRET,
  {
    app_id: "YOUR_APP_ID",
    target: "https://your-server.com/webhook",
    target_type: "HTTP",
    triggers: ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
  },
)
  .then((webhook) => {
    console.log("Webhook created:", webhook);
  })
  .catch((error) => {
    console.error("Error:", error.message);
  });
```

## Key Points

1. **Maximum 5 webhooks per app** — check existing webhooks before creating new ones
2. **HTTPS required** — target URL must use HTTPS protocol
3. **URL length limit** — maximum 742 characters for target URL
4. **Regional endpoint** — use region matching your Conversation API app
5. **Triggers array** — specify which events to subscribe to (see available triggers in SKILL.md)
6. **OAuth2.0 configuration** — optional, for Sinch to authenticate when calling your webhook
7. **HMAC secret** — optional, for you to verify callback signatures
8. **Immediate activation** — callbacks start immediately after webhook creation
9. **Error handling** — 400 for invalid request, 403 for permission/quota errors
10. **Response includes webhook ID** — save this ID for update/delete operations
