# Create Webhook - Python Example

## Using sinch SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
    project_id="YOUR_PROJECT_ID"
)

def create_webhook():
    try:
        webhook = sinch_client.conversation.webhooks.create(
            app_id="YOUR_APP_ID",
            target="https://your-server.com/webhook",
            target_type="HTTP",
            triggers=[
                "MESSAGE_INBOUND",
                "MESSAGE_DELIVERY",
                "EVENT_INBOUND"
            ],
            secret="your-webhook-secret-for-hmac",  # Optional
            # Optional: OAuth2.0 configuration
            client_credentials={
                "client_id": "your-oauth-client-id",
                "client_secret": "your-oauth-client-secret",
                "endpoint": "https://your-server.com/oauth2/token",
                "scope": "webhooks",
                "token_request_type": "BASIC"  # or "FORM"
            }
        )

        print(f"Webhook created: {webhook}")
        print(f"Webhook ID: {webhook.id}")

        return webhook
    except Exception as error:
        print(f"Failed to create webhook: {error}")
        raise

create_webhook()
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

# Step 2: Create webhook
def create_webhook(project_id, access_token, webhook_data):
    region = os.getenv("SINCH_REGION", "us")

    response = requests.post(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks",
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        },
        json=webhook_data
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

        webhook = create_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            token,
            {
                "app_id": "YOUR_APP_ID",
                "target": "https://your-server.com/webhook",
                "target_type": "HTTP",
                "triggers": ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
                "secret": "your-webhook-secret"
            }
        )

        print(f"Webhook created: {json.dumps(webhook, indent=2)}")
    except Exception as error:
        print(f"Error: {error}")
```

## Raw HTTP with Basic Auth (Testing Only)

```python
import requests
import os
import json
from base64 import b64encode

def create_webhook(project_id, key_id, key_secret, webhook_data):
    region = os.getenv("SINCH_REGION", "us")
    auth_header = b64encode(f"{key_id}:{key_secret}".encode()).decode()

    response = requests.post(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks",
        headers={
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/json"
        },
        json=webhook_data
    )

    response.raise_for_status()
    return response.json()

# Usage
if __name__ == "__main__":
    try:
        webhook = create_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            os.getenv("SINCH_KEY_ID"),
            os.getenv("SINCH_KEY_SECRET"),
            {
                "app_id": "YOUR_APP_ID",
                "target": "https://your-server.com/webhook",
                "target_type": "HTTP",
                "triggers": ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"]
            }
        )

        print(f"Webhook created: {json.dumps(webhook, indent=2)}")
    except requests.exceptions.HTTPError as error:
        print(f"HTTP Error: {error.response.status_code} - {error.response.text}")
    except Exception as error:
        print(f"Error: {error}")
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
9. **Error handling** — HTTPError for 400/403/500 response codes
10. **Response includes webhook ID** — save this ID for update/delete operations
