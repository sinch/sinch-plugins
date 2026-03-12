---
name: sinch-numbers
description: Sinch Numbers API integration for fetching and managing active phone numbers. Use when working with Sinch phone numbers for: (1) Fetching active phone numbers from Sinch Numbers API, (2) Generating code to interact with numbers in TypeScript, Python, or Java.
---

# Numbers

Fetch and manage active phone numbers from the Sinch Numbers API with multilingual code generation support.

## Agent Instructions

Before generating any code, ask the user the following in a single prompt:

1. **Approach** — Use the **Conversation API SDK** (`@sinch/sdk-core` for Node.js, `sinch` for Python) or **direct API calls** (plain HTTP via `fetch`, `axios`, `curl`, etc.)?
2. **Language** — Which language? (Node.js/TypeScript, Python, Java, curl/bash, etc.)

Default to the **SDK approach** if the user is in a Node.js/TypeScript or Python context and the SDK is already installed. Only ask if it's unclear.

## Overview

This skill provides tools and code generation patterns for working with Sinch phone numbers across TypeScript, Python, and Java. It includes an executable script for fetching numbers and comprehensive reference documentation for implementing number management in your applications.

## Quick Start

### Fetch Numbers with Script

```bash
node scripts/get_numbers.cjs \
  --project-id YOUR_PROJECT_ID \
  --key-id YOUR_KEY_ID \
  --key-secret YOUR_KEY_SECRET
```

With environment variables:

```bash
export SINCH_PROJECT_ID="your-project-id"
export SINCH_KEY_ID="your-key-id"
export SINCH_KEY_SECRET="your-key-secret"

node scripts/get_numbers.cjs --output numbers.json
```

## Code Generation

### Language Selection

Generate code in the user's preferred language:

- **TypeScript**: See [references/typescript.md](references/typescript.md) for service classes, type definitions, React hooks, and Node.js examples
- **Python**: See [references/python.md](references/python.md) for service classes, dataclasses, Pydantic models, async implementations, and Flask examples
- **Java**: See [references/java.md](references/java.md) for service classes, model POJOs, Spring integration, and error handling

### SDK-First Approach

**Prefer Conversation API SDK.** Use the official SDK when possible — it handles authentication and API communication automatically. Fallback to direct API calls only if the SDK is not available.

### Common Patterns

All languages support:
- SDK-based authentication (preferred) or manual OAuth2 credentials
- Fetching active numbers with pagination
- Managing selected number state
- Comprehensive error handling
- HTTP client abstraction (fallback only)

## API Details

### Endpoint

```
GET https://numbers.api.sinch.com/v1/projects/{projectId}/activeNumbers
```

### Authentication

For detailed authentication setup, see the [authentication skill](../authentication/SKILL.md).

The Numbers API uses OAuth2 authentication with:
- **Project ID**: Your Sinch project identifier
- **Key ID + Key Secret**: Access key credentials from your Sinch dashboard

**Quick Example (Using SDK):**

```javascript
import { SinchClient } from '@sinch/sdk-core';

const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID,
  keyId: process.env.SINCH_KEY_ID,
  keySecret: process.env.SINCH_KEY_SECRET,
});

// Fetch active numbers
const response = await sinch.numbers.activeNumber.list({
  projectId: process.env.SINCH_PROJECT_ID,
});

console.log('Active numbers:', response.activeNumbers);
```

**Python SDK:**

```python
from sinch import SinchClient

sinch_client = SinchClient(
    project_id="YOUR_PROJECT_ID",
    key_id="YOUR_KEY_ID",
    key_secret="YOUR_KEY_SECRET"
)

# Fetch active numbers
response = sinch_client.numbers.active_number.list(
    project_id=sinch_client.project_id
)

print("Active numbers:", response.active_numbers)
```

**Java SDK:**

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;

Configuration config = Configuration.builder()
    .setProjectId("YOUR_PROJECT_ID")
    .setKeyId("YOUR_KEY_ID")
    .setKeySecret("YOUR_KEY_SECRET")
    .build();

SinchClient sinch = new SinchClient(config);

// Fetch active numbers
var response = sinch.numbers().activeNumber().list(
    ListActiveNumbersRequest.builder()
        .setProjectId(config.getProjectId())
        .build()
);

System.out.println("Active numbers: " + response.getActiveNumbers());
```

### Query Parameters

- `pageSize`: Number of results per page (default: 100)
- `pageToken`: Token for pagination (optional)

### Response Structure

```json
{
  "activeNumbers": [
    {
      "phoneNumber": "+12345678900",
      "projectId": "project-id",
      "displayName": "My Number",
      "regionCode": "US",
      "type": "LOCAL",
      "capability": ["SMS", "VOICE"],
      "smsConfiguration": { ... },
      "voiceConfiguration": { ... }
    }
  ]
}
```

## Workflow

### For Generating Code

1. Ask user which language they need (TypeScript, Python, or Java)
2. Read the appropriate reference file for that language
3. **Always prefer the official SDK** (`@sinch/sdk-core` for Node.js, `sinch` for Python, Maven SDK for Java)
   - Check if the SDK is available in the user's project (e.g., `package.json`, `requirements.txt`, `pom.xml`)
   - If SDK is present → generate SDK-based code
   - If SDK is absent → generate direct HTTP API call code as fallback
4. Include proper types/models based on the language
5. Add error handling appropriate for the language

### For Fetching Numbers

1. If user needs to actually fetch numbers, use `scripts/get_numbers.cjs`
2. Ask for credentials or use environment variables
3. Execute script with proper parameters
4. Return results or save to file

## Resources

This skill includes:

### scripts/
- `get_numbers.cjs`: Fetch active phone numbers from Sinch Numbers API

### references/
- `typescript.md`: TypeScript patterns, types, service classes, and React examples
- `python.md`: Python patterns, dataclasses/Pydantic models, async implementations
- `java.md`: Java patterns, POJOs, Spring integration, and error handling

Load the appropriate reference file when generating code for a specific language.
