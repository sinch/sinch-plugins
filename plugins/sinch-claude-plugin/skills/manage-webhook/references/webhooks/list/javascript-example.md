# List Webhooks - JavaScript Example

## Using @sinch/sdk-core

```javascript
import { SinchClient } from "@sinch/sdk-core";

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

async function listWebhooks() {
  try {
    const webhooks = await sinch.conversation.webhooks.list({
      app_id: "YOUR_APP_ID",
    });

    console.log("Webhooks:", webhooks);
    console.log(`Found ${webhooks.length} webhooks`);

    webhooks.forEach((webhook) => {
      console.log(`- ${webhook.id}: ${webhook.target}`);
      console.log(`  Triggers: ${webhook.triggers.join(", ")}`);
    });

    return webhooks;
  } catch (error) {
    console.error("Failed to list webhooks:", error);
    throw error;
  }
}

listWebhooks();
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

// Step 2: List webhooks
async function listWebhooks(projectId, appId, accessToken) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/apps/${appId}/webhooks`,
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
          reject(new Error(`List webhooks failed: ${res.statusCode} ${data}`));
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

    const webhooks = await listWebhooks(
      process.env.SINCH_PROJECT_ID,
      "YOUR_APP_ID",
      token,
    );

    console.log("Webhooks:", JSON.stringify(webhooks, null, 2));
  } catch (error) {
    console.error("Error:", error.message);
  }
})();
```

## Raw HTTP with Basic Auth (Testing Only)

```javascript
const https = require("https");

function listWebhooks(projectId, appId, keyId, keySecret) {
  return new Promise((resolve, reject) => {
    const region = process.env.SINCH_REGION || "us";
    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");

    const options = {
      hostname: `${region}.conversation.api.sinch.com`,
      path: `/v1/projects/${projectId}/apps/${appId}/webhooks`,
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
listWebhooks(
  process.env.SINCH_PROJECT_ID,
  "YOUR_APP_ID",
  process.env.SINCH_KEY_ID,
  process.env.SINCH_KEY_SECRET,
)
  .then((webhooks) => {
    console.log("Webhooks:", webhooks);
  })
  .catch((error) => {
    console.error("Error:", error.message);
  });
```

## Key Points

1. **App scoped** — list returns only webhooks for specified app_id
2. **Maximum 5 webhooks per app** — list will return at most 5 webhooks
3. **No pagination** — all webhooks returned in single response
4. **Regional endpoint** — use region matching your Conversation API app
5. **Returns array** — empty array if no webhooks configured
6. **Full webhook objects** — includes id, target, triggers, secret (masked), client_credentials
7. **Error handling** — 404 if app_id not found, 403 for permission errors
8. **Lightweight operation** — safe to call frequently for monitoring
9. **Use for validation** — check existing webhooks before creating new ones
10. **Active webhooks only** — does not include deleted webhooks
