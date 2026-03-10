# List Webhooks - Python Example

## Using sinch SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
    project_id="YOUR_PROJECT_ID"
)

def list_webhooks():
    try:
        webhooks = sinch_client.conversation.webhooks.list(
            app_id="YOUR_APP_ID"
        )

        print(f"Webhooks: {webhooks}")
        print(f"Found {len(webhooks)} webhooks")

        for webhook in webhooks:
            print(f"- {webhook.id}: {webhook.target}")
            print(f"  Triggers: {', '.join(webhook.triggers)}")

        return webhooks
    except Exception as error:
        print(f"Failed to list webhooks: {error}")
        raise

list_webhooks()
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

# Step 2: List webhooks
def list_webhooks(project_id, app_id, access_token):
    region = os.getenv("SINCH_REGION", "us")

    response = requests.get(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/apps/{app_id}/webhooks",
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

        webhooks = list_webhooks(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_APP_ID",
            token
        )

        print(f"Webhooks: {json.dumps(webhooks, indent=2)}")
    except Exception as error:
        print(f"Error: {error}")
```

## Raw HTTP with Basic Auth (Testing Only)

```python
import requests
import os
import json
from base64 import b64encode

def list_webhooks(project_id, app_id, key_id, key_secret):
    region = os.getenv("SINCH_REGION", "us")
    auth_header = b64encode(f"{key_id}:{key_secret}".encode()).decode()

    response = requests.get(
        f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/apps/{app_id}/webhooks",
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
        webhooks = list_webhooks(
            os.getenv("SINCH_PROJECT_ID"),
            "YOUR_APP_ID",
            os.getenv("SINCH_KEY_ID"),
            os.getenv("SINCH_KEY_SECRET")
        )

        print(f"Webhooks: {json.dumps(webhooks, indent=2)}")
    except requests.exceptions.HTTPError as error:
        print(f"HTTP Error: {error.response.status_code} - {error.response.text}")
    except Exception as error:
        print(f"Error: {error}")
```

## Key Points

1. **App scoped** — list returns only webhooks for specified app_id
2. **Maximum 5 webhooks per app** — list will return at most 5 webhooks
3. **No pagination** — all webhooks returned in single response
4. **Regional endpoint** — use region matching your Conversation API app
5. **Returns array** — empty array if no webhooks configured
6. **Full webhook objects** — includes id, target, triggers, secret (masked), client_credentials
7. **Error handling** — HTTPError for 404 if app not found, 403 for permission errors
8. **Lightweight operation** — safe to call frequently for monitoring
9. **Use for validation** — check existing webhooks before creating new ones
10. **Active webhooks only** — does not include deleted webhooks
