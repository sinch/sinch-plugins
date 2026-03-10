# Update Webhook - JavaScript Example

## Using @sinch/sdk-core

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

async function updateWebhook() {
  try {
    const webhook = await sinch.conversation.webhooks.update({
      webhook_id: "YOUR_WEBHOOK_ID",
      updateWebhookRequestBody: {
        target: "https://your-new-server.com/webhook",
        triggers: [
          "MESSAGE_INBOUND",
          "MESSAGE_DELIVERY",
          "EVENT_INBOUND",
          "CONVERSATION_START",
        ],
        secret: "new-webhook-secret",
      },
      update_mask: ["target", "triggers", "secret"], // Specify which fields to update
    });

    console.log("Webhook updated:", webhook);
    console.log("New target:", webhook.target);

    return webhook;
  } catch (error) {
    console.error("Failed to update webhook:", error);
    throw error;
  }
}

updateWebhook();
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

// Step 2: Update webhook
async function updateWebhook(
  projectId,
  webhookId,
  accessToken,
  updateData,
  updateMask,
) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";
    const payload = JSON.stringify(updateData);
    const maskParam = updateMask.join(",");

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks/${webhookId}?update_mask=${encodeURIComponent(maskParam)}`,
      method: "PATCH",
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
          reject(new Error(`Update webhook failed: ${res.statusCode} ${data}`));
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

    const webhook = await updateWebhook(
      process.env.SINCH_PROJECT_ID,
      "YOUR_WEBHOOK_ID",
      token,
      {
        target: "https://your-new-server.com/webhook",
        triggers: ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
      },
      ["target", "triggers"],
    );

    console.log("Webhook updated:", JSON.stringify(webhook, null, 2));
  } catch (error) {
    console.error("Error:", error.message);
  }
})();
```

## Raw HTTP with Basic Auth (Testing Only)

```javascript
const https = require("https");

function updateWebhook(
  projectId,
  webhookId,
  keyId,
  keySecret,
  updateData,
  updateMask,
) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";
    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");
    const payload = JSON.stringify(updateData);
    const maskParam = updateMask.join(",");

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks/${webhookId}?update_mask=${encodeURIComponent(maskParam)}`,
      method: "PATCH",
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
updateWebhook(
  process.env.SINCH_PROJECT_ID,
  "YOUR_WEBHOOK_ID",
  process.env.SINCH_KEY_ID,
  process.env.SINCH_KEY_SECRET,
  {
    target: "https://your-new-server.com/webhook",
    triggers: ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
  },
  ["target", "triggers"],
)
  .then((webhook) => {
    console.log("Webhook updated:", webhook);
  })
  .catch((error) => {
    console.error("Error:", error.message);
  });
```

## Key Points

1. **update_mask required** — must specify which fields to update (e.g., `target`, `triggers`, `secret`)
2. **Partial updates** — only fields in update_mask are modified, others remain unchanged
3. **Webhook ID required** — use the ID returned from create or list operations
4. **Regional endpoint** — use region matching your Conversation API app
5. **Cannot change app_id** — webhooks are permanently bound to their original app
6. **Triggers replacement** — triggers array replaces existing triggers completely
7. **Immediate effect** — updated configuration takes effect immediately
8. **Error handling** — 404 if webhook_id not found, 400 for invalid update_mask or data
9. **OAuth2.0 update** — can update client_credentials to change OAuth2.0 config
10. **Returns complete webhook** — response includes all fields with updated values
