# Python - Numbers Code Generation

This reference provides Python patterns for fetching and managing Sinch active phone numbers using the Sinch SDK.

## Table of Contents
- [Core Service Implementation](#core-service-implementation)
- [Type Definitions](#type-definitions)
- [SDK Integration](#sdk-integration)
- [Error Handling](#error-handling)
- [Usage Examples](#usage-examples)

## Core Service Implementation

### NumberService Class (Using Sinch SDK)

```python
from sinch import SinchClient
from typing import List, Dict, Optional
from dataclasses import dataclass


@dataclass
class SinchConfig:
    project_id: str
    key_id: str
    key_secret: str


class NumberService:
    def __init__(self, config: SinchConfig):
        self.config = config
        self.client = SinchClient(
            project_id=config.project_id,
            key_id=config.key_id,
            key_secret=config.key_secret
        )

    def load_numbers(self, page_size: int = 100) -> List[Dict]:
        """
        Fetch active phone numbers from Sinch Numbers API.
        
        Args:
            page_size: Number of results per page
            
        Returns:
            List of active phone numbers
        """
        try:
            response = self.client.numbers.active_number.list(
                project_id=self.config.project_id,
                page_size=page_size
            )
            return response.active_numbers or []
        except Exception as e:
            print(f"Failed to load numbers: {e}")
            raise

    def get_number_by_phone(self, phone_number: str) -> Optional[Dict]:
        """Get a specific active number by phone number."""
        try:
            number = self.client.numbers.active_number.get(
                project_id=self.config.project_id,
                phone_number=phone_number
            )
            return number
        except Exception as e:
            print(f"Failed to get number {phone_number}: {e}")
            return None

    def get_selected_number(self, storage: Dict, key: str = "selectedNumber") -> Optional[str]:
        """Get the currently selected number from storage."""
        return storage.get(key)

    def set_selected_number(self, storage: Dict, phone_number: str, key: str = "selectedNumber") -> None:
        """Set the currently selected number in storage."""
        storage[key] = phone_number

    def clear_selected_number(self, storage: Dict, key: str = "selectedNumber") -> None:
        """Clear the currently selected number from storage."""
        storage.pop(key, None)
```

## Type Definitions

### Using Pydantic (Recommended for Data Validation)

```python
from pydantic import BaseModel, Field
from typing import List, Optional


class Money(BaseModel):
    currency_code: str = Field(..., alias="currencyCode")
    amount: str


class SmsConfiguration(BaseModel):
    service_plan_id: str = Field(..., alias="servicePlanId")
    schedule_provisioning: Optional[str] = Field(None, alias="scheduleProvisioning")
    campaign_id: str = Field(..., alias="campaignId")


class VoiceConfiguration(BaseModel):
    app_id: str = Field(..., alias="appId")
    schedule_voice_provisioning: Optional[str] = Field(None, alias="scheduleVoiceProvisioning")
    last_updated_time: Optional[str] = Field(None, alias="lastUpdatedTime")
    type: str
    trunk_id: str = Field(..., alias="trunkId")
    service_id: str = Field(..., alias="serviceId")


class ActiveNumber(BaseModel):
    phone_number: str = Field(..., alias="phoneNumber")
    project_id: str = Field(..., alias="projectId")
    display_name: str = Field(..., alias="displayName")
    region_code: str = Field(..., alias="regionCode")
    type: str
    callback_url: str = Field(..., alias="callbackUrl")
    capability: List[str]
    expire_at: str = Field(..., alias="expireAt")
    money: Money
    next_charge_date: str = Field(..., alias="nextChargeDate")
    payment_interval_months: int = Field(..., alias="paymentIntervalMonths")
    sms_configuration: SmsConfiguration = Field(..., alias="smsConfiguration")
    voice_configuration: VoiceConfiguration = Field(..., alias="voiceConfiguration")

    class Config:
        populate_by_name = True
```

### Using Dataclasses (Built-in Alternative)

```python
from dataclasses import dataclass
from typing import List, Optional


@dataclass
class Money:
    currency_code: str
    amount: str


@dataclass
class SmsConfiguration:
    service_plan_id: str
    schedule_provisioning: Optional[str]
    campaign_id: str


@dataclass
class VoiceConfiguration:
    app_id: str
    schedule_voice_provisioning: Optional[str]
    last_updated_time: Optional[str]
    type: str
    trunk_id: str
    service_id: str


@dataclass
class ActiveNumber:
    phone_number: str
    project_id: str
    display_name: str
    region_code: str
    type: str
    callback_url: str
    capability: List[str]
    expire_at: str
    money: Money
    next_charge_date: str
    payment_interval_months: int
    sms_configuration: SmsConfiguration
    voice_configuration: VoiceConfiguration
```

## SDK Integration

### Simple Function Approach

```python
from sinch import SinchClient


def get_numbers(project_id: str, key_id: str, key_secret: str, page_size: int = 100):
    """Fetch active numbers from Sinch Numbers API using SDK."""
    sinch_client = SinchClient(
        project_id=project_id,
        key_id=key_id,
        key_secret=key_secret
    )
    
    response = sinch_client.numbers.active_number.list(
        project_id=project_id,
        page_size=page_size
    )
    
    return response.active_numbers or []
```

### With Pagination

```python
def get_all_numbers(project_id: str, key_id: str, key_secret: str):
    """Fetch all active numbers with pagination."""
    sinch_client = SinchClient(
        project_id=project_id,
        key_id=key_id,
        key_secret=key_secret
    )
    
    all_numbers = []
    page_token = None
    
    while True:
        response = sinch_client.numbers.active_number.list(
            project_id=project_id,
            page_size=100,
            page_token=page_token
        )
        
        all_numbers.extend(response.active_numbers or [])
        
        if not response.next_page_token:
            break
            
        page_token = response.next_page_token
    
    return all_numbers
```

### Async Implementation

```python
import asyncio
from sinch import SinchClient
from typing import List, Dict


async def get_numbers_async(
    project_id: str,
    key_id: str,
    key_secret: str,
    page_size: int = 100
) -> List[Dict]:
    """Asynchronously fetch active numbers using SDK."""
    # Note: Sinch Python SDK uses sync API internally
    # This wraps it in an async context for integration with async frameworks
    
    def fetch():
        sinch_client = SinchClient(
            project_id=project_id,
            key_id=key_id,
            key_secret=key_secret
        )
        response = sinch_client.numbers.active_number.list(
            project_id=project_id,
            page_size=page_size
        )
        return response.active_numbers or []
    
    # Run in thread pool to avoid blocking
    loop = asyncio.get_event_loop()
    numbers = await loop.run_in_executor(None, fetch)
    return numbers


# Usage
# numbers = asyncio.run(get_numbers_async(project_id, key_id, key_secret))
```

## Error Handling

### Custom Exception Classes

```python
class NumberError(Exception):
    """Base exception for number operations."""
    pass


class NumberAPIError(NumberError):
    """Exception raised for API errors."""
    def __init__(self, message: str, status_code: int = None, response: Dict = None):
        self.message = message
        self.status_code = status_code
        self.response = response
        super().__init__(self.message)


class NumberAuthError(NumberError):
    """Exception raised for authentication errors."""
    pass


class NumberNotFoundError(NumberError):
    """Exception raised when a number is not found."""
    pass


def get_numbers_with_error_handling(
    project_id: str,
    key_id: str,
    key_secret: str,
    page_size: int = 100
) -> List[Dict]:
    """Fetch numbers with comprehensive error handling."""
    try:
        sinch_client = SinchClient(
            project_id=project_id,
            key_id=key_id,
            key_secret=key_secret
        )
        
        response = sinch_client.numbers.active_number.list(
            project_id=project_id,
            page_size=page_size
        )
        
        return response.active_numbers or []
        
    except Exception as e:
        error_message = str(e).lower()
        
        if "401" in error_message or "unauthorized" in error_message:
            raise NumberAuthError("Authentication failed. Check your credentials.")
        elif "404" in error_message or "not found" in error_message:
            raise NumberNotFoundError("Project not found or no active numbers.")
        elif "timeout" in error_message:
            raise NumberAPIError("Request timed out")
        else:
            raise NumberAPIError(f"Failed to fetch numbers: {e}")
```

## Usage Examples

### Basic Usage

```python
from sinch import SinchClient

# Initialize and fetch numbers
config = SinchConfig(
    project_id="your-project-id",
    key_id="your-key-id",
    key_secret="your-key-secret"
)

service = NumberService(config)
numbers = service.load_numbers()

print(f"Found {len(numbers)} active numbers")
for number in numbers:
    phone = number.get('phoneNumber') if isinstance(number, dict) else number.phone_number
    num_type = number.get('type') if isinstance(number, dict) else number.type
    print(f"{phone} - {num_type}")
```

### With Environment Variables

```python
import os
from sinch import SinchClient

# Load from environment
sinch_client = SinchClient(
    project_id=os.getenv("SINCH_PROJECT_ID"),
    key_id=os.getenv("SINCH_KEY_ID"),
    key_secret=os.getenv("SINCH_KEY_SECRET")
)

response = sinch_client.numbers.active_number.list(
    project_id=os.getenv("SINCH_PROJECT_ID")
)

numbers = response.active_numbers or []
print(f"Found {len(numbers)} numbers")
```

### Flask API Endpoint

```python
from flask import Flask, jsonify, request
from sinch import SinchClient
import os

app = Flask(__name__)

# Initialize Sinch client once
sinch_client = SinchClient(
    project_id=os.getenv("SINCH_PROJECT_ID"),
    key_id=os.getenv("SINCH_KEY_ID"),
    key_secret=os.getenv("SINCH_KEY_SECRET")
)


@app.route('/api/numbers', methods=['GET'])
def get_numbers_endpoint():
    try:
        region_code = request.args.get('regionCode')
        number_type = request.args.get('type')
        
        response = sinch_client.numbers.active_number.list(
            project_id=os.getenv("SINCH_PROJECT_ID"),
            region_code=region_code,
            type=number_type,
            page_size=100
        )
        
        numbers = response.active_numbers or []
        
        return jsonify({
            "success": True,
            "count": len(numbers),
            "numbers": numbers
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


@app.route('/api/numbers/<phone_number>', methods=['GET'])
def get_number_endpoint(phone_number):
    try:
        number = sinch_client.numbers.active_number.get(
            project_id=os.getenv("SINCH_PROJECT_ID"),
            phone_number=phone_number
        )
        
        return jsonify({
            "success": True,
            "number": number
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 404


if __name__ == '__main__':
    app.run(debug=True)
```

### CLI Tool

```python
import argparse
import json
from sinch import SinchClient


def main():
    parser = argparse.ArgumentParser(description="Fetch Sinch active numbers")
    parser.add_argument("--project-id", required=True, help="Sinch project ID")
    parser.add_argument("--key-id", required=True, help="Access key ID")
    parser.add_argument("--key-secret", required=True, help="Access key secret")
    parser.add_argument("--output", help="Output file path (JSON)")
    parser.add_argument("--region", help="Filter by region code (e.g., US)")
    parser.add_argument("--type", help="Filter by type (LOCAL, MOBILE, TOLL_FREE)")
    
    args = parser.parse_args()
    
    # Initialize Sinch client
    sinch_client = SinchClient(
        project_id=args.project_id,
        key_id=args.key_id,
        key_secret=args.key_secret
    )
    
    # Fetch numbers
    print("Fetching active numbers...", file=sys.stderr)
    response = sinch_client.numbers.active_number.list(
        project_id=args.project_id,
        region_code=args.region,
        type=args.type,
        page_size=100
    )
    
    numbers = response.active_numbers or []
    print(f"Found {len(numbers)} numbers", file=sys.stderr)
    
    # Output results
    result = {
        "count": len(numbers),
        "numbers": numbers
    }
    
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(result, f, indent=2)
        print(f"Saved to {args.output}", file=sys.stderr)
    else:
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    import sys
    main()
```

### Django View Example

```python
from django.http import JsonResponse
from django.views import View
from sinch import SinchClient
from django.conf import settings


class NumbersListView(View):
    def __init__(self):
        super().__init__()
        self.sinch_client = SinchClient(
            project_id=settings.SINCH_PROJECT_ID,
            key_id=settings.SINCH_KEY_ID,
            key_secret=settings.SINCH_KEY_SECRET
        )
    
    def get(self, request):
        try:
            region_code = request.GET.get('region')
            number_type = request.GET.get('type')
            
            response = self.sinch_client.numbers.active_number.list(
                project_id=settings.SINCH_PROJECT_ID,
                region_code=region_code,
                type=number_type
            )
            
            numbers = response.active_numbers or []
            
            return JsonResponse({
                'success': True,
                'count': len(numbers),
                'numbers': numbers
            })
        except Exception as e:
            return JsonResponse({
                'success': False,
                'error': str(e)
            }, status=500)
```
