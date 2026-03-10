---
description: Generate code to fetch Sinch active numbers/senders and handle sender operations
argument-hint: [generate | debug | explain | pagination | freestyle]
---

# Sinch Conversation API - List Active Senders

This command helps you work with the Sinch Numbers API to retrieve your active phone numbers/senders. Prefer the SDK-first approach when possible.

**User Request**: $ARGUMENTS

## Instructions

1. Parse user request from $ARGUMENTS.

2. If no arguments or generic request (e.g., "list active senders", "help"):
   Display the quick reference with numbered options:
   ```
   Sinch Numbers API - Active Senders

   API Endpoint: GET https://numbers.api.sinch.com/v1/projects/{projectId}/activeNumbers

   What would you like to do?
   1. Generate code - Create a function to fetch active senders (SDK or direct API)
   2. Debug issues - Troubleshoot sender retrieval problems
   3. Explain the API - Learn about the endpoint and response structure
   4. Add pagination - Handle large datasets
   5. Freestyle - Describe your own request or question
   ```

3. If user selects option 1 or requests code generation (e.g., "generate", "create function", "implement", "1"):

   Ask which **approach** (SDK vs direct API) and **language** (Node.js, Python, Java) if not already specified. Default to SDK if the project has the SDK installed.

   **Node.js SDK (preferred):**
   ```javascript
   import { SinchClient } from '@sinch/sdk-core';

   const sinch = new SinchClient({
     projectId: process.env.SINCH_PROJECT_ID,
     keyId: process.env.SINCH_KEY_ID,
     keySecret: process.env.SINCH_KEY_SECRET,
   });

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

   var response = sinch.numbers().activeNumber().list(
       ListActiveNumbersRequest.builder()
           .setProjectId(config.getProjectId())
           .build()
   );

   System.out.println("Active numbers: " + response.getActiveNumbers());
   ```

   **Direct API (TypeScript fallback if SDK is not available):**
   ```typescript
   interface Numbers {
     phoneNumber: string;
     projectId: string;
     displayName: string;
     regionCode: string;
     type: string;
     capability: string[];
   }

   async function loadSenders(projectId: string, authToken: string): Promise<Numbers[]> {
     const response = await fetch(
       `https://numbers.api.sinch.com/v1/projects/${projectId}/activeNumbers?page_size=100`,
       {
         method: 'GET',
         headers: {
           'Authorization': `Bearer ${authToken}`,
           'Content-Type': 'application/json',
         },
       }
     );

     if (!response.ok) {
       throw new Error(`Failed to load senders: ${response.status}`);
     }

     const data = await response.json();
     return data.activeNumbers;
   }
   ```

   **curl shortcut:**
   ```bash
   curl -s "https://numbers.api.sinch.com/v1/projects/$SINCH_PROJECT_ID/activeNumbers?page_size=100" \
     -H "Authorization: Bearer $ACCESS_TOKEN"
   ```

4. If user selects option 2 or asks about debugging/troubleshooting (e.g., "debug", "error", "2"):
   List common error scenarios:
   - 401 Unauthorized: Invalid or expired auth token
   - 404 Not Found: Invalid project ID
   - 429 Too Many Requests: Rate limiting
   - Network errors: Connectivity issues
   - Missing configuration: Environment variables not set

5. If user selects option 3 or asks about API structure (e.g., "explain", "api", "3"):
   Explain endpoint details:
   - **Base URL**: `https://numbers.api.sinch.com/v1`
   - **Path**: `/projects/{projectId}/activeNumbers`
   - **Method**: GET
   - **Query Parameters**: `page_size` (default: 100), `page_token` (for pagination)
   - **Auth**: Bearer token (OAuth2) or SDK handles auth automatically
   - **SDKs**: `@sinch/sdk-core` (Node.js), `sinch` (Python), `com.sinch.sdk:sinch-sdk-java` (Java)

6. If user selects option 4 or asks about pagination (e.g., "pagination", "4"):
   Provide pagination implementation with `page_token` handling.

7. If user selects option 5 or provides freestyle input (e.g., "freestyle", "5", or any custom question/request):
   Ask the user to describe what they need help with regarding the Sinch Numbers API or active senders.
   Then provide a tailored response based on their specific request, using the API information and code patterns from this command as reference.

8. If user asks for full type definitions or detailed response structure:
   ```typescript
   interface Numbers {
     phoneNumber: string;
     projectId: string;
     displayName: string;
     regionCode: string;
     type: string;
     callbackUrl: string;
     capability: string[];
     expireAt: string;
     money: { currencyCode: string; amount: string };
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

## Key Principle
Keep responses concise. Only show code when user explicitly requests it or selects option 1. Default to SDK approach when possible — it handles authentication automatically.
