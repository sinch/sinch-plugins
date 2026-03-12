# Update Webhook - Python Example

## Using sinch SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
    project_id="YOUR_PROJECT_ID"
)

def update_webhook():
    try:
        webhook = sinch_client.conversation.webhooks.update(
            webhook_id="YOUR_WEBHOOK_ID",
            target="https://your-new-server.com/webhook",
            triggers=[
                "MESSAGE_INBOUND",
                "MESSAGE_DELIVERY",
                "EVENT_INBOUND",
                "CONVERSATION_START"
            ],
            secret="new-webhook-secret",
            update_mask=["target", "triggers", "secret"]  # Specify which fields to update
        )

        print(f"Webhook updated: {webhook}")
        print(f"New target: {webhook.target}")

        return webhook
    except Exception as error:
        print(f"Failed to update webhook: {error}")
        raise

update_webhook()
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

# Step 2: Update webhook
def update_webhook(project_id, webhook_id, access_token, update_data, update_mask):
    region = os.getenv("SINCH_REGION", "us")
    mask_param = ",".join(update_mask)

    response = requests.patch(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks/{webhook_id}",
        params={"update_mask": mask_param},
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        },
        json=update_data
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

        webhook = update_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_WEBHOOK_ID",
            token,
            {
                "target": "https://your-new-server.com/webhook",
                "triggers": ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"]
            },
            ["target", "triggers"]
        )

        print(f"Webhook updated: {json.dumps(webhook, indent=2)}")
    except Exception as error:
        print(f"Error: {error}")
```

## Raw HTTP with Basic Auth (Testing Only)

```python
import requests
import os
import json
from base64 import b64encode

def update_webhook(project_id, webhook_id, key_id, key_secret, update_data, update_mask):
    region = os.getenv("SINCH_REGION", "us")
    auth_header = b64encode(f"{key_id}:{key_secret}".encode()).decode()
    mask_param = ",".join(update_mask)

    response = requests.patch(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks/{webhook_id}",
        params={"update_mask": mask_param},
        headers={
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/json"
        },
        json=update_data
    )

    response.raise_for_status()
    return response.json()

# Usage
if __name__ == "__main__":
    try:
        webhook = update_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_WEBHOOK_ID",
            os.getenv("SINCH_KEY_ID"),
            os.getenv("SINCH_KEY_SECRET"),
            {
                "target": "https://your-new-server.com/webhook",
                "triggers": ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"]
            },
            ["target", "triggers"]
        )

        print(f"Webhook updated: {json.dumps(webhook, indent=2)}")
    except requests.exceptions.HTTPError as error:
        print(f"HTTP Error: {error.response.status_code} - {error.response.text}")
    except Exception as error:
        print(f"Error: {error}")
```

## Key Points

1. **update_mask required** — must specify which fields to update (e.g., `target`, `triggers`, `secret`)
2. **Partial updates** — only fields in update_mask are modified, others remain unchanged
3. **Webhook ID required** — use the ID returned from create or list operations
4. **Regional endpoint** — use region matching your Conversation API app
5. **Cannot change app_id** — webhooks are permanently bound to their original app
6. **Triggers replacement** — triggers array replaces existing triggers completely
7. **Immediate effect** — updated configuration takes effect immediately
8. **Error handling** — HTTPError for 404 if webhook not found, 400 for invalid update_mask or data
9. **OAuth2.0 update** — can update client_credentials to change OAuth2.0 config
10. **Returns complete webhook** — response includes all fields with updated values
