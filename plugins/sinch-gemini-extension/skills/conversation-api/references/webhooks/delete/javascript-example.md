# Delete Webhook - JavaScript Example

## Using @sinch/sdk-core

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

async function deleteWebhook() {
  try {
    await sinch.conversation.webhooks.delete({
      webhook_id: "YOUR_WEBHOOK_ID",
    });

    console.log("Webhook deleted successfully");
  } catch (error) {
    console.error("Failed to delete webhook:", error);
    throw error;
  }
}

deleteWebhook();
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

// Step 2: Delete webhook
async function deleteWebhook(projectId, webhookId, accessToken) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks/${webhookId}`,
      method: "DELETE",
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
          resolve();
        } else {
          reject(new Error(`Delete webhook failed: ${res.statusCode} ${data}`));
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

    await deleteWebhook(process.env.SINCH_PROJECT_ID, "YOUR_WEBHOOK_ID", token);

    console.log("Webhook deleted successfully");
  } catch (error) {
    console.error("Error:", error.message);
  }
})();
```

## Raw HTTP with Basic Auth (Testing Only)

```javascript
const https = require("https");

function deleteWebhook(projectId, webhookId, keyId, keySecret) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";
    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/webhooks/${webhookId}`,
      method: "DELETE",
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
          resolve();
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
deleteWebhook(
  process.env.SINCH_PROJECT_ID,
  "YOUR_WEBHOOK_ID",
  process.env.SINCH_KEY_ID,
  process.env.SINCH_KEY_SECRET,
)
  .then(() => {
    console.log("Webhook deleted successfully");
  })
  .catch((error) => {
    console.error("Error:", error.message);
  });
```

## Key Points

1. **Webhook ID required** — use the ID returned from create or list operations
2. **Immediate effect** — webhook stops receiving callbacks immediately
3. **Cannot be undone** — deletion is permanent, must recreate to restore
4. **Regional endpoint** — use region matching your Conversation API app
5. **Empty response** — successful deletion returns 200 status with no body
6. **Error handling** — 404 if webhook_id not found, 403 for permission errors
7. **Safe to retry** — deleting non-existent webhook returns 404 (not idempotent)
8. **No cascade effects** — deleting webhook does not affect app or messages
9. **Cleanup recommended** — delete unused webhooks to stay within 5 per app limit
10. **Project scoped** — webhook_id must belong to specified project_id
