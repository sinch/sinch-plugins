# Python Examples

## Send SMS — Using sinch SDK

```python
import os
from sinch import SinchClient

sinch_client = SinchClient(
    project_id=os.environ["SINCH_PROJECT_ID"],
    key_id=os.environ["SINCH_KEY_ID"],
    key_secret=os.environ["SINCH_KEY_SECRET"],
)
sinch_client.configuration.conversation_region = os.environ.get("SINCH_REGION", "us")

response = sinch_client.conversation.message.send(
    app_id=os.environ["SINCH_APP_ID"],
    recipient={
        "identified_by": {
            "channel_identities": [
                {"channel": "SMS", "identity": "+15551234567"}
            ]
        }
    },
    message={"text_message": {"text": "Hello from Sinch!"}},
    channel_properties={"SMS_SENDER": "+15559876543"},
)

print(f"Message sent: {response.message_id}")
```

## Send SMS with Fallback — Using sinch SDK

```python
response = sinch_client.conversation.message.send(
    app_id=os.environ["SINCH_APP_ID"],
    channel_priority_order=["WHATSAPP", "SMS"],
    recipient={
        "identified_by": {
            "channel_identities": [
                {"channel": "WHATSAPP", "identity": "+15551234567"},
                {"channel": "SMS", "identity": "+15551234567"},
            ]
        }
    },
    message={"text_message": {"text": "Your order has shipped!"}},
)
```

## Send SMS as a Function — Using sinch SDK

```python
import os
from sinch import SinchClient


def send_sms(to: str, text: str, sender: str | None = None):
    sinch_client = SinchClient(
        project_id=os.environ["SINCH_PROJECT_ID"],
        key_id=os.environ["SINCH_KEY_ID"],
        key_secret=os.environ["SINCH_KEY_SECRET"],
    )
    sinch_client.configuration.conversation_region = os.environ.get("SINCH_REGION", "us")

    recipient = {
        "identified_by": {
            "channel_identities": [{"channel": "SMS", "identity": to}]
        }
    }
    message = {"text_message": {"text": text}}
    channel_properties = {"SMS_SENDER": sender} if sender else None

    response = sinch_client.conversation.message.send(
        app_id=os.environ["SINCH_APP_ID"],
        recipient=recipient,
        message=message,
        channel_properties=channel_properties,
    )
    return response


# Usage
result = send_sms(to="+15551234567", text="Hello from Sinch!")
print(f"Message sent: {result.message_id}")
```

## List Messages — Using requests

> **Note:** The Python SDK's `message.list()` does not support filtering by `channel` or
> `channel_identity`. Use the REST API with `requests` for those filters.

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


def list_messages(
    contact_id: str | None = None,
    conversation_id: str | None = None,
    channel: str | None = None,
    channel_identity: str | None = None,
    page_size: int = 10,
    page_token: str | None = None,
) -> dict:
    token = get_token(os.environ["SINCH_KEY_ID"], os.environ["SINCH_KEY_SECRET"])
    region = os.environ.get("SINCH_REGION", "us")
    project_id = os.environ["SINCH_PROJECT_ID"]

    url = f"https://{region}.conversation.api.sinch.com/v1/projects/{project_id}/messages"

    params = {"page_size": page_size}
    if contact_id:
        params["contact_id"] = contact_id
    if conversation_id:
        params["conversation_id"] = conversation_id
    if channel:
        params["channel"] = channel
    if channel_identity:
        params["channel_identity"] = channel_identity
    if page_token:
        params["page_token"] = page_token

    resp = requests.get(
        url,
        headers={"Authorization": f"Bearer {token}"},
        params=params,
    )
    resp.raise_for_status()
    return resp.json()


# Usage
result = list_messages(channel="SMS", page_size=10)
for msg in result.get("messages", []):
    direction = msg.get("direction", "UNKNOWN")
    accept_time = msg.get("accept_time", "")
    contact_msg = msg.get("contact_message", {})
    app_msg = msg.get("app_message", {})
    text = ""
    if contact_msg:
        text = contact_msg.get("text_message", {}).get("text", "")
    elif app_msg:
        text = app_msg.get("text_message", {}).get("text", "")
    print(f"[{accept_time}] {direction}: {text}")
```

## Send Template Message — Using sinch SDK

```python
response = sinch_client.conversation.message.send(
    app_id=os.environ["SINCH_APP_ID"],
    recipient={
        "identified_by": {
            "channel_identities": [
                {"channel": "SMS", "identity": "+15551234567"}
            ]
        }
    },
    message={
        "template_message": {
            "omni_template": {
                "template_id": "YOUR_TEMPLATE_ID",
                "version": "1",
                "parameters": {
                    "name": {"literal_parameter": {"value": "John"}}
                },
            }
        }
    },
)
```

## Async Send — Using sinch SDK

```python
import asyncio
import os
from sinch import SinchClientAsync


async def main():
    sinch_client = SinchClientAsync(
        project_id=os.environ["SINCH_PROJECT_ID"],
        key_id=os.environ["SINCH_KEY_ID"],
        key_secret=os.environ["SINCH_KEY_SECRET"],
    )
    sinch_client.configuration.conversation_region = os.environ.get("SINCH_REGION", "us")

    response = await sinch_client.conversation.message.send(
        app_id=os.environ["SINCH_APP_ID"],
        recipient={
            "identified_by": {
                "channel_identities": [
                    {"channel": "SMS", "identity": "+15551234567"}
                ]
            }
        },
        message={"text_message": {"text": "Hello async!"}},
    )
    print(f"Sent: {response.message_id}")


asyncio.run(main())
```
