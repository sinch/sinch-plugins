# RCS Location Message - Python Examples

## Overview

RCS location messages share precise geographic coordinates with a title and label. The RCS client renders these as interactive buttons that open the user's map app when tapped. Ideal for store locations, meeting points, delivery addresses, or any situation requiring precise location sharing.

## Send RCS Location — Using Python SDK

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
            "location_message": {
                "title": "Our Store Location",
                "label": "Visit us at 123 Main Street, Downtown",
                "coordinates": {
                    "latitude": 40.7128,
                    "longitude": -74.0060,
                },
            }
        },
    }
)

print(f"Location sent: {response.message_id}")
```

## Send RCS Location — Using Python requests (no SDK)

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

def send_rcs_location(to: str, title: str, label: str, latitude: float, longitude: float) -> dict:
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
        "message": {
            "location_message": {
                "title": title,
                "label": label,
                "coordinates": {
                    "latitude": latitude,
                    "longitude": longitude,
                },
            }
        },
    }

    resp = requests.post(
        url,
        headers={"Authorization": f"Bearer {token}"},
        json=body,
    )
    resp.raise_for_status()
    return resp.json()

# Usage
result = send_rcs_location(
    "+15551234567",
    "Meeting Point",
    "Meet me here at 3 PM",
    40.7128,
    -74.0060
)
print(result)
```

## Key Points

- **Title:** Short name for the location (e.g., "Our Store")
- **Label:** Additional context (e.g., "Visit us at 123 Main St")
- **Coordinates:** Latitude and longitude (decimal degrees)
- **Rendering:** RCS transcodes to text with a location choice button
- **User action:** Tapping opens map app with the coordinates
- **SMS fallback:** Sent as text with Google Maps URL
- **Use cases:** Store locations, meeting points, delivery addresses, ride-sharing pickup
- **Accuracy:** Use precise coordinates for best user experience
