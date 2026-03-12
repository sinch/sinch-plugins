# Get Webhook - Python Example

## Using sinch SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
    project_id="YOUR_PROJECT_ID"
)

def get_webhook():
    try:
        webhook = sinch_client.conversation.webhooks.get(
            webhook_id="YOUR_WEBHOOK_ID"
        )

        print(f"Webhook: {webhook}")
        print(f"ID: {webhook.id}")
        print(f"Target: {webhook.target}")
        print(f"Triggers: {webhook.triggers}")
        print(f"App ID: {webhook.app_id}")

        return webhook
    except Exception as error:
        print(f"Failed to get webhook: {error}")
        raise

get_webhook()
```

## Raw HTTP with OAuth2.0

```python
import requests
import os
import json
from base64 import b64encode

# Step 1: Get access token
def get_access_token(key_id, key_secret):
    auth_header = b64encode(f"{key_id}:{key_secret}".encode()).decode()

    response = requests.post(
        "https://auth.sinch.com/oauth2/token",
        headers={
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/x-www-form-urlencoded"
        },
        data={"grant_type": "client_credentials"}
    )

    response.raise_for_status()
    return response.json()["access_token"]

# Step 2: Get webhook
def get_webhook(project_id, webhook_id, access_token):
    region = os.getenv("SINCH_REGION", "us")

    response = requests.get(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks/{webhook_id}",
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
    )

    response.raise_for_status()
    return response.json()

# Usage
if __name__ == "__main__":
    try:
        token = get_access_token(
            os.getenv("SINCH_KEY_ID"),
            os.getenv("SINCH_KEY_SECRET")
        )

        webhook = get_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_WEBHOOK_ID",
            token
        )

        print(f"Webhook: {json.dumps(webhook, indent=2)}")
    except Exception as error:
        print(f"Error: {error}")
```

## Raw HTTP with Basic Auth (Testing Only)

```python
import requests
import os
import json
from base64 import b64encode

def get_webhook(project_id, webhook_id, key_id, key_secret):
    region = os.getenv("SINCH_REGION", "us")
    auth_header = b64encode(f"{key_id}:{key_secret}".encode()).decode()

    response = requests.get(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks/{webhook_id}",
        headers={
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/json"
        }
    )

    response.raise_for_status()
    return response.json()

# Usage
if __name__ == "__main__":
    try:
        webhook = get_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_WEBHOOK_ID",
            os.getenv("SINCH_KEY_ID"),
            os.getenv("SINCH_KEY_SECRET")
        )

        print(f"Webhook: {json.dumps(webhook, indent=2)}")
    except requests.exceptions.HTTPError as error:
        print(f"HTTP Error: {error.response.status_code} - {error.response.text}")
    except Exception as error:
        print(f"Error: {error}")
```

## Key Points

1. **Webhook ID required** — use the ID returned from create or list operations
2. **Project scoped** — webhook_id must belong to specified project_id
3. **Regional endpoint** — use region matching your Conversation API app
4. **Full webhook details** — returns complete configuration including masked secret
5. **Error handling** — HTTPError for 404 if webhook not found, 403 for permission errors
6. **Includes app_id** — response shows which app the webhook belongs to
7. **Client credentials included** — OAuth2.0 config (if set) returned with client_secret masked
8. **Use for verification** — check webhook configuration before update
9. **Lightweight operation** — safe to call frequently for monitoring
10. **Active webhooks only** — cannot retrieve deleted webhooks
