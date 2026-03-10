# Delete Webhook - Python Example

## Using sinch SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
    project_id="YOUR_PROJECT_ID"
)

def delete_webhook():
    try:
        sinch_client.conversation.webhooks.delete(
            webhook_id="YOUR_WEBHOOK_ID"
        )

        print("Webhook deleted successfully")
    except Exception as error:
        print(f"Failed to delete webhook: {error}")
        raise

delete_webhook()
```

## Raw HTTP with OAuth2.0

```python
import requests
import os
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

# Step 2: Delete webhook
def delete_webhook(project_id, webhook_id, access_token):
    region = os.getenv("SINCH_REGION", "us")

    response = requests.delete(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks/{webhook_id}",
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
    )

    response.raise_for_status()

# Usage
if __name__ == "__main__":
    try:
        token = get_access_token(
            os.getenv("SINCH_KEY_ID"),
            os.getenv("SINCH_KEY_SECRET")
        )

        delete_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_WEBHOOK_ID",
            token
        )

        print("Webhook deleted successfully")
    except Exception as error:
        print(f"Error: {error}")
```

## Raw HTTP with Basic Auth (Testing Only)

```python
import requests
import os
from base64 import b64encode

def delete_webhook(project_id, webhook_id, key_id, key_secret):
    region = os.getenv("SINCH_REGION", "us")
    auth_header = b64encode(f"{key_id}:{key_secret}".encode()).decode()

    response = requests.delete(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/webhooks/{webhook_id}",
        headers={
            "Authorization": f"Basic {auth_header}",
            "Content-Type": "application/json"
        }
    )

    response.raise_for_status()

# Usage
if __name__ == "__main__":
    try:
        delete_webhook(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_WEBHOOK_ID",
            os.getenv("SINCH_KEY_ID"),
            os.getenv("SINCH_KEY_SECRET")
        )

        print("Webhook deleted successfully")
    except requests.exceptions.HTTPError as error:
        print(f"HTTP Error: {error.response.status_code} - {error.response.text}")
    except Exception as error:
        print(f"Error: {error}")
```

## Key Points

1. **Webhook ID required** — use the ID returned from create or list operations
2. **Immediate effect** — webhook stops receiving callbacks immediately
3. **Cannot be undone** — deletion is permanent, must recreate to restore
4. **Regional endpoint** — use region matching your Conversation API app
5. **Empty response** — successful deletion returns 200 status with no body
6. **Error handling** — HTTPError for 404 if webhook not found, 403 for permission errors
7. **Safe to retry** — deleting non-existent webhook returns 404 (not idempotent)
8. **No cascade effects** — deleting webhook does not affect app or messages
9. **Cleanup recommended** — delete unused webhooks to stay within 5 per app limit
10. **Project scoped** — webhook_id must belong to specified project_id
