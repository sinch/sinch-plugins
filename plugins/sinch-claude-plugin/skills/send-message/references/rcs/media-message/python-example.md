# RCS Media Message - Python Examples

## Overview

RCS media messages deliver standalone images, videos, or audio files via HTTPS URLs. For videos, you can specify an optional thumbnail image for preview. Media messages are simple standalone content delivery; for media with text or buttons, use card or carousel messages instead.

## Send RCS Media — Using Python SDK

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
            "media_message": {"url": "https://example.com/image.jpg"}
        },
    }
)

print(f"Media sent: {response.message_id}")
```

## Send RCS Media — Using Python requests (no SDK)

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

def send_rcs_media(to: str, media_url: str, thumbnail_url: str = None) -> dict:
    token = get_token(os.environ["SINCH_KEY_ID"], os.environ["SINCH_KEY_SECRET"])
    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages:send"

    media_message = {"url": media_url}
    if thumbnail_url:
        media_message["thumbnail_url"] = thumbnail_url

    body = {
        "app_id": os.environ["SINCH_APP_ID"],
        "recipient": {
            "identified_by": {
                "channel_identities": [{"channel": "RCS", "identity": to}]
            }
        },
        "message": {"media_message": media_message},
    }

    resp = requests.post(
        url,
        headers={"Authorization": f"Bearer {token}"},
        json=body,
    )
    resp.raise_for_status()
    return resp.json()

# Usage
result = send_rcs_media("+15551234567", "https://example.com/photo.jpg")
print(result)
```

## Key Points

- **Media types:** Images (JPG, PNG, GIF), videos (MP4), audio (MP3, AAC)
- **File size:** Max 10MB for images, 100MB for videos
- **URL requirement:** Must be HTTPS and publicly accessible
- **Thumbnail:** Optional for videos; enhances preview experience
- **Caching:** Media URLs are cached for 28 days by carriers
- **SMS fallback:** Media sent as URL link in text message
- **Use cards:** For media with text/buttons, use card or carousel messages
