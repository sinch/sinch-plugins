# List RCS Messages - Python Examples

## Overview

Retrieve message history from RCS conversations using the Sinch Conversation API. The list messages endpoint supports filtering by contact, conversation, channel, time range, and pagination.

**Key Parameters:**

- `app_id` - Your Conversation API app ID (required)
- `channel` - Filter by channel (e.g., "RCS")
- `contact_id` - Filter by specific contact
- `conversation_id` - Filter by specific conversation
- `page_size` - Number of messages per page (default: 10, max: 1000)
- `page_token` - Token for next page in pagination
- `start_time` - Filter messages after this time (ISO 8601)
- `end_time` - Filter messages before this time (ISO 8601)

**Authentication:** OAuth2 Bearer token or Basic Auth with base64(`keyId:keySecret`)

## Using Sinch Python SDK

```python
import os
from sinch import SinchClient

sinch_client = SinchClient(
    project_id=os.environ["SINCH_PROJECT_ID"],
    key_id=os.environ["SINCH_KEY_ID"],
    key_secret=os.environ["SINCH_KEY_SECRET"],
)

# List recent RCS messages
response = sinch_client.conversation.messages.list(
    app_id=os.environ["SINCH_APP_ID"],
    channel="RCS",
    page_size=20,
)

print(f"Found {len(response.messages)} messages")
for msg in response.messages:
    print(f"{msg.id}: {msg.direction} at {msg.accept_time}")

# Pagination
if response.next_page_token:
    next_page = sinch_client.conversation.messages.list(
        app_id=os.environ["SINCH_APP_ID"],
        page_token=response.next_page_token,
    )
```

## List Messages for Specific Contact

```python
response = sinch_client.conversation.messages.list(
    app_id=os.environ["SINCH_APP_ID"],
    contact_id="01GXXX...",  # Contact ID
    channel="RCS",
    page_size=50,
)
```

## List Messages with Time Filter

```python
response = sinch_client.conversation.messages.list(
    app_id=os.environ["SINCH_APP_ID"],
    channel="RCS",
    start_time="2024-01-01T00:00:00Z",
    end_time="2024-12-31T23:59:59Z",
    page_size=100,
)
```

## Using requests with OAuth2 (no SDK)

```python
import os
import requests
from urllib.parse import urlencode

def get_token(key_id: str, key_secret: str) -> str:
    resp = requests.post(
        "https://auth.sinch.com/oauth2/token",
        auth=(key_id, key_secret),
        data={"grant_type": "client_credentials"},
    )
    resp.raise_for_status()
    return resp.json()["access_token"]

def list_rcs_messages(page_size: int = 10) -> dict:
    token = get_token(
        os.environ["SINCH_KEY_ID"],
        os.environ["SINCH_KEY_SECRET"],
    )

    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]
    app_id = os.environ["SINCH_APP_ID"]

    params = {
        "app_id": app_id,
        "channel": "RCS",
        "page_size": page_size,
    }

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages"

    resp = requests.get(
        url,
        headers={"Authorization": f"Bearer {token}"},
        params=params,
    )
    resp.raise_for_status()
    return resp.json()

# Usage
result = list_rcs_messages(20)
print(result)
```

## Using requests with Basic Auth (no SDK, no OAuth)

```python
import os
import base64
import requests

def list_rcs_messages_basic_auth(page_size: int = 10) -> dict:
    key_id = os.environ["SINCH_KEY_ID"]
    key_secret = os.environ["SINCH_KEY_SECRET"]
    credentials = base64.b64encode(f"{key_id}:{key_secret}".encode()).decode()

    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]
    app_id = os.environ["SINCH_APP_ID"]

    params = {
        "app_id": app_id,
        "channel": "RCS",
        "page_size": page_size,
    }

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages"

    resp = requests.get(
        url,
        headers={"Authorization": f"Basic {credentials}"},
        params=params,
    )
    resp.raise_for_status()
    return resp.json()

# Usage
result = list_rcs_messages_basic_auth(20)
print(result)
```

## Key Points

- **Default sort:** Messages returned in descending order by `accept_time` (most recent first)
- **Pagination:** Use `next_page_token` from response to fetch next page
- **Max page size:** 1000 messages per request
- **Time filters:** Use ISO 8601 format for `start_time` and `end_time`
- **Channel filter:** "RCS" to get only RCS messages
- **Contact filter:** Requires valid contact ID from Conversation API
- **Authentication:** Supports both OAuth2 Bearer tokens and Basic Auth
- **Message details:** Each message includes ID, direction, channel, content, timestamps, status
