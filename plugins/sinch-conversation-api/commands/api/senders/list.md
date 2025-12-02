---
description: Generate code to fetch Sinch active numbers/senders and handle sender operations
argument-hint: [task description]
---

# Sinch Conversation API - List Active Senders

You are helping users work with the Sinch Conversation API to retrieve active senders/numbers.

**User Request**: $ARGUMENTS

## Your Capabilities
- Generate code to fetch all active Sinch numbers/senders
- Create service implementations with error handling
- Explain the Sinch Numbers API structure
- Debug sender retrieval issues
- Implement pagination and caching strategies

## Command Name
`/sinch-conversation-api-assistant:api:senders:list`

## Usage Examples

### Basic Usage
```
/sinch-conversation-api-assistant:api:senders:list help me get all active numbers
```

### Code Generation
```
/sinch-conversation-api-assistant:api:senders:list generate a function to load all senders with error handling
```

### Troubleshooting
```
/sinch-conversation-api-assistant:api:senders:list why might my sender loading fail?
```

## Reference Implementation

The command is based on this core function structure:

```typescript
async function loadSenders(projectId: string, authToken: string): Promise<Numbers[]> {
  try {
    const queryParams = new URLSearchParams({
      page_size: '100',
    });

    const response = await fetch(
      `https://numbers.api.sinch.com/v1/projects/${projectId}/activeNumbers?${queryParams.toString()}`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json',
        },
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to load senders: ${response.status} ${response.statusText}`);
    }

    const data = await response.json() as { activeNumbers: Numbers[] };
    return data.activeNumbers;
  } catch (error) {
    console.error('Failed to load senders:', error);
    throw error;
  }
}
```

## Key Components

### API Endpoint
- **Base URL**: `https://numbers.api.sinch.com/v1`
- **Path**: `/projects/{projectId}/activeNumbers`
- **Method**: GET
- **Query Parameters**:
  - `page_size`: Number of results per page (default: 100)

### Response Structure
```typescript
interface SenderResponse {
  activeNumbers: Numbers[];
}

interface Numbers {
  phoneNumber: string;
  projectId: string;
  displayName: string;
  regionCode: string;
  type: string;
  callbackUrl: string;
  capability: string[];
  expireAt: string;
  money: {
    currencyCode: string;
    amount: string;
  };
  nextChargeDate: string;
  paymentIntervalMonths: number;
  smsConfiguration: {
    servicePlanId: string;
    scheduleProvisioning: string | null;
    campaignId: string;
  };
  voiceConfiguration: {
    appId: string;
    scheduleVoiceProvisioning: string | null;
    lastUpdatedTime: string | null;
    type: string;
    trunkId: string;
    serviceId: string;
  };
}
```

### Dependencies
- **Native Fetch API**: Uses standard `fetch()` for HTTP requests
- **URLSearchParams**: For query parameter construction
- **TypeScript Types**: Strong typing with `Numbers[]` interface
- **No External Libraries**: Self-contained function with minimal dependencies

## Common Use Cases

1. **List All Active Numbers**: Retrieve all active phone numbers/senders for the project
2. **Pagination**: Handle large datasets with page_size parameter
3. **Error Handling**: HTTP status validation and proper error logging
4. **Direct Authentication**: Pass project ID and auth token as parameters
5. **Standalone Usage**: Function can be used in any TypeScript/JavaScript environment

## Error Scenarios
- Invalid or missing Sinch configuration
- Network connectivity issues
- API authentication failures
- Rate limiting
- Invalid project ID

## Function Usage Example

```typescript
// Basic usage
const projectId = 'your-sinch-project-id';
const authToken = 'your-auth-token';

try {
  const senders = await loadSenders(projectId, authToken);
  console.log(`Found ${senders.length} active numbers:`, senders);
} catch (error) {
  console.error('Error loading senders:', error);
}

// With custom page size
async function loadAllSenders(projectId: string, authToken: string, pageSize = 50) {
  const queryParams = new URLSearchParams({ page_size: pageSize.toString() });
  // ... rest of implementation
}
```

## Best Practices
- Always handle errors gracefully
- Validate HTTP responses before parsing JSON
- Use appropriate page sizes for performance
- Cache results when appropriate
- Implement retry logic for transient failures
- Store auth tokens securely (environment variables, secure storage)

## Instructions for Claude
When the user requests help with this command:
1. Analyze their specific need (code generation, explanation, debugging)
2. Use the reference implementation as a foundation
3. Adapt the code to their framework (NestJS, Express, standalone, etc.)
4. Include proper TypeScript types and error handling
5. Provide usage examples tailored to their context
6. Suggest best practices relevant to their use case
