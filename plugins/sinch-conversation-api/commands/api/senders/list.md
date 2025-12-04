---
description: Generate code to fetch Sinch active numbers/senders and handle sender operations
argument-hint: [generate | debug | explain | pagination | freestyle]
---

# Sinch Conversation API - List Active Senders

This command helps you work with the Sinch Numbers API to retrieve your active phone numbers/senders.

**User Request**: $ARGUMENTS

## Instructions

1. Parse user request from $ARGUMENTS.

2. If no arguments or generic request (e.g., "list active senders", "help"):
   Display the quick reference with numbered options:
   ```
   Sinch Numbers API - Active Senders

   API Endpoint: GET https://numbers.api.sinch.com/v1/projects/{projectId}/activeNumbers

   What would you like to do?
   1. Generate code - Create a function to fetch active senders
   2. Debug issues - Troubleshoot sender retrieval problems
   3. Explain the API - Learn about the endpoint and response structure
   4. Add pagination - Handle large datasets
   5. Freestyle - Describe your own request or question
   ```

3. If user selects option 1 or requests code generation (e.g., "generate", "create function", "implement", "1"):
   Provide the implementation:
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

   Usage:
   ```typescript
   const senders = await loadSenders(process.env.CONVERSATION_PROJECT_ID, authToken);
   console.log(`Found ${senders.length} active numbers`);
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
   - **Query Parameters**: `page_size` (default: 100)
   - **Auth**: Bearer token

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
Keep responses concise. Only show code when user explicitly requests it or selects option 1.
