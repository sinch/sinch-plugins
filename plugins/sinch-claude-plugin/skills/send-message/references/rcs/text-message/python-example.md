# RCS Text Message - Python Examples

## Overview

RCS text messages support up to 3072 UTF-8 characters with full emoji support. They provide native delivery and read receipts, making them ideal for transactional and conversational messaging. Use the `curl` command below to send a quick test:

```bash
curl -X POST "https://us.conversation.api.sinch.com/v1/projects/YOUR_PROJECT_ID/messages:send" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "recipient": {
      "identified_by": {
        "channel_identities": [{"channel": "RCS", "identity": "+15551234567"}]
      }
    },
    "message": {"text_message": {"text": "Hello from RCS!"}}
  }'
```

## Send RCS Text — Using Python SDK

```python
from sinch import SinchClient

sinch_client = SinchClient(
    project_id="YOUR_PROJECT_ID",
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET",
)

response = sinch_client.conversation.messages.send(
    send_message_request_body={
        "app_id": "YOUR_APP_ID",
        "recipient": {
            "identified_by": {
                "channel_identities": [
                    {"channel": "RCS", "identity": "+15551234567"}
                ]
            }
        },
        "message": {
            "text_message": {"text": "Hello from RCS!"}
        },
    }
)

print(f"Message sent: {response.message_id}")
```

## Send RCS Text — Using Python requests (no SDK)

```python
import os
import requests

def get_token(key_id: str, key_secret: str) -> str:
    resp = requests.post(
        "https://auth.sinch.com/oauth2/token",
        auth=(key_id, key_secret),
        data={"grant_type": "client_credentials"},
    )
    resp.raise_for_status()
    return resp.json()["access_token"]

def send_rcs_text(to: str, text: str) -> dict:
    token = get_token(os.environ["SINCH_KEY_ID"], os.environ["SINCH_KEY_SECRET"])
    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages:send"

    body = {
        "app_id": os.environ["SINCH_APP_ID"],
        "recipient": {
            "identified_by": {
                "channel_identities": [{"channel": "RCS", "identity": to}]
            }
        },
        "message": {"text_message": {"text": text}},
    }

    resp = requests.post(
        url,
        headers={"Authorization": f"Bearer {token}"},
        json=body,
    )
    resp.raise_for_status()
    return resp.json()

# Usage
result = send_rcs_text("+15551234567", "Hello from RCS!")
print(result)
```

## Key Points

- **Max length:** RCS text messages support up to 3072 characters
- **Encoding:** UTF-8 (supports all Unicode characters including emojis)
- **Delivery receipts:** Native support for delivered, read, and failed statuses
- **Typing indicators:** Can be sent separately using composing events
- **SMS fallback:** Always recommended for critical messages
- **Rich text:** Plain text only; use card/carousel messages for rich formatting
