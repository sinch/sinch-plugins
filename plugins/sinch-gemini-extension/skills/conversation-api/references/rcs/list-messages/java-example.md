# List RCS Messages - Java Examples

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

**Authentication:** OAuth2 Bearer token or Basic Auth with Base64(`keyId:keySecret`)

## Using Sinch Java SDK

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.conversation.models.v1.messages.request.ListMessagesRequest;
import com.sinch.sdk.domains.conversation.models.v1.messages.response.ListMessagesResponse;

public class ListRcsMessages {
    public static void main(String[] args) {
        // Initialize Sinch client
        Configuration config = Configuration.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .build();

        SinchClient sinch = new SinchClient(config);

        // List recent RCS messages
        ListMessagesRequest request = ListMessagesRequest.builder()
                .setAppId(System.getenv("SINCH_APP_ID"))
                .setChannel("RCS")
                .setPageSize(20)
                .build();

        ListMessagesResponse response = sinch.conversation()
                .messages()
                .list(request);

        System.out.println("Found " + response.getMessages().size() + " messages");
        response.getMessages().forEach(msg -> {
            System.out.println(msg.getId() + ": " + msg.getDirection() + " at " + msg.getAcceptTime());
        });

        // Pagination
        if (response.getNextPageToken() != null) {
            ListMessagesRequest nextRequest = ListMessagesRequest.builder()
                    .setAppId(System.getenv("SINCH_APP_ID"))
                    .setPageToken(response.getNextPageToken())
                    .build();

            ListMessagesResponse nextPage = sinch.conversation()
                    .messages()
                    .list(nextRequest);
        }
    }
}
```

## List Messages for Specific Contact

```java
ListMessagesRequest request = ListMessagesRequest.builder()
        .setAppId(System.getenv("SINCH_APP_ID"))
        .setContactId("01GXXX...")  // Contact ID
        .setChannel("RCS")
        .setPageSize(50)
        .build();

ListMessagesResponse response = sinch.conversation()
        .messages()
        .list(request);
```

## List Messages with Time Filter

```java
import java.time.Instant;

ListMessagesRequest request = ListMessagesRequest.builder()
        .setAppId(System.getenv("SINCH_APP_ID"))
        .setChannel("RCS")
        .setStartTime(Instant.parse("2024-01-01T00:00:00Z"))
        .setEndTime(Instant.parse("2024-12-31T23:59:59Z"))
        .setPageSize(100)
        .build();

ListMessagesResponse response = sinch.conversation()
        .messages()
        .list(request);
```

## Using HttpURLConnection with OAuth2 (no SDK)

```java
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import org.json.JSONObject;

public class ListRcsMessagesNoSDK {

    private static String getOAuth2Token(String keyId, String keySecret) throws IOException {
        String credentials = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes(StandardCharsets.UTF_8));

        URL url = new URL("https://auth.sinch.com/oauth2/token");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "Basic " + credentials);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write("grant_type=client_credentials".getBytes(StandardCharsets.UTF_8));
        }

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            JSONObject json = new JSONObject(response.toString());
            return json.getString("access_token");
        }
    }

    public static String listMessages(int pageSize) throws IOException {
        String token = getOAuth2Token(
                System.getenv("SINCH_KEY_ID"),
                System.getenv("SINCH_KEY_SECRET")
        );

        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String projectId = System.getenv("SINCH_PROJECT_ID");
        String appId = System.getenv("SINCH_APP_ID");

        String urlStr = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/messages?app_id=%s&channel=RCS&page_size=%d",
                region, projectId, appId, pageSize
        );

        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + token);

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            return response.toString();
        }
    }

    public static void main(String[] args) throws IOException {
        String result = listMessages(20);
        System.out.println(result);
    }
}
```

## Using HttpURLConnection with Basic Auth (no SDK, no OAuth)

```java
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class ListRcsMessagesBasicAuth {

    public static String listMessages(int pageSize) throws IOException {
        String keyId = System.getenv("SINCH_KEY_ID");
        String keySecret = System.getenv("SINCH_KEY_SECRET");
        String credentials = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes(StandardCharsets.UTF_8));

        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String projectId = System.getenv("SINCH_PROJECT_ID");
        String appId = System.getenv("SINCH_APP_ID");

        String urlStr = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/messages?app_id=%s&channel=RCS&page_size=%d",
                region, projectId, appId, pageSize
        );

        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Basic " + credentials);

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            return response.toString();
        }
    }

    public static void main(String[] args) throws IOException {
        String result = listMessages(20);
        System.out.println(result);
    }
}
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
- **Dependencies:** Java SDK uses Sinch SDK for Java; no-SDK examples require org.json for JSON parsing
