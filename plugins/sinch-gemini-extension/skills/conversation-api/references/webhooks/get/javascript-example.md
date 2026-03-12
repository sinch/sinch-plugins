# Get Webhook - JavaScript Example

## Using @sinch/sdk-core

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

async function getWebhook() {
  try {
    const webhook = await sinch.conversation.webhooks.get({
      webhook_id: "YOUR_WEBHOOK_ID",
    });

    console.log("Webhook:", webhook);
    console.log("ID:", webhook.id);
    console.log("Target:", webhook.target);
    console.log("Triggers:", webhook.triggers);
    console.log("App ID:", webhook.app_id);

    return webhook;
  } catch (error) {
    console.error("Failed to get webhook:", error);
    throw error;
  }
}

getWebhook();
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

// Step 2: Get webhook
async function getWebhook(projectId, webhookId, accessToken) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks/${webhookId}`,
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(data));
        } else {
          reject(new Error(`Get webhook failed: ${res.statusCode} ${data}`));
        }
      });
    });

    req.on("error", reject);
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

    const webhook = await getWebhook(
      process.env.SINCH_PROJECT_ID,
      "YOUR_WEBHOOK_ID",
      token,
    );

    console.log("Webhook:", JSON.stringify(webhook, null, 2));
  } catch (error) {
    console.error("Error:", error.message);
  }
})();
```

## Raw HTTP with Basic Auth (Testing Only)

```javascript
const https = require("https");

function getWebhook(projectId, webhookId, keyId, keySecret) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";
    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks/${webhookId}`,
      method: "GET",
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/json",
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
    req.end();
  });
}

// Usage
getWebhook(
  process.env.SINCH_PROJECT_ID,
  "YOUR_WEBHOOK_ID",
  process.env.SINCH_KEY_ID,
  process.env.SINCH_KEY_SECRET,
)
  .then((webhook) => {
    console.log("Webhook:", webhook);
  })
  .catch((error) => {
    console.error("Error:", error.message);
  });
```

## Key Points

1. **Webhook ID required** — use the ID returned from create or list operations
2. **Project scoped** — webhook_id must belong to specified project_id
3. **Regional endpoint** — use region matching your Conversation API app
4. **Full webhook details** — returns complete configuration including masked secret
5. **Error handling** — 404 if webhook_id not found, 403 for permission errors
6. **Includes app_id** — response shows which app the webhook belongs to
7. **Client credentials included** — OAuth2.0 config (if set) returned with client_secret masked
8. **Use for verification** — check webhook configuration before update
9. **Lightweight operation** — safe to call frequently for monitoring
10. **Active webhooks only** — cannot retrieve deleted webhooks
