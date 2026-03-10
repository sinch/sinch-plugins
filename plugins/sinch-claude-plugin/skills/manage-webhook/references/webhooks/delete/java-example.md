# Delete Webhook - Java Example

## Using sinch-sdk-java

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.domains.conversation.api.v1.WebhooksService;
import com.sinch.sdk.models.ConversationRegion;

public class DeleteWebhookExample {
    public static void main(String[] args) {
        SinchClient sinchClient = SinchClient.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .setConversationRegion(ConversationRegion.US)  // or EU, BR
                .build();

        try {
            WebhooksService webhooksService = sinchClient.conversation().v1().webhooks();

            // Delete webhook by ID
            webhooksService.delete("YOUR_WEBHOOK_ID");

            System.out.println("Webhook deleted successfully");

        } catch (Exception e) {
            System.err.println("Failed to delete webhook: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Raw HTTP with OAuth2.0

```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublishers;
import java.util.Base64;
import org.json.JSONObject;

public class DeleteWebhookRawOAuth {
    private static final HttpClient client = HttpClient.newHttpClient();

    // Step 1: Get access token
    public static String getAccessToken(String keyId, String keySecret) throws Exception {
        String auth = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes());

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://auth.sinch.com/oauth2/token"))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(BodyPublishers.ofString("grant_type=client_credentials"))
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Auth failed: " + response.statusCode() + " " + response.body());
        }

        return new JSONObject(response.body()).getString("access_token");
    }

    // Step 2: Delete webhook
    public static void deleteWebhook(String projectId, String webhookId,
            String accessToken) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/webhooks/%s",
                region, projectId, webhookId);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + accessToken)
                .header("Content-Type", "application/json")
                .DELETE()
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Delete webhook failed: " + response.statusCode() +
                    " " + response.body());
        }
    }

    // Usage
    public static void main(String[] args) {
        try {
            String token = getAccessToken(
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET")
            );

            deleteWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_WEBHOOK_ID",
                    token
            );

            System.out.println("Webhook deleted successfully");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Raw HTTP with Basic Auth (Testing Only)

```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Base64;

public class DeleteWebhookRawBasic {
    private static final HttpClient client = HttpClient.newHttpClient();

    public static void deleteWebhook(String projectId, String webhookId,
            String keyId, String keySecret) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/webhooks/%s",
                region, projectId, webhookId);

        String auth = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes());

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/json")
                .DELETE()
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Failed: " + response.statusCode() + " " + response.body());
        }
    }

    // Usage
    public static void main(String[] args) {
        try {
            deleteWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_WEBHOOK_ID",
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET")
            );

            System.out.println("Webhook deleted successfully");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Key Points

1. **Webhook ID required** — use the ID returned from create or list operations
2. **Immediate effect** — webhook stops receiving callbacks immediately
3. **Cannot be undone** — deletion is permanent, must recreate to restore
4. **Regional endpoint** — use `ConversationRegion.US`, `.EU`, or `.BR` matching your app
5. **Empty response** — successful deletion returns 200 status with no body
6. **Exception handling** — catch API exceptions for 404 if webhook not found, 403 for permission errors
7. **Safe to retry** — deleting non-existent webhook returns 404 (not idempotent)
8. **No cascade effects** — deleting webhook does not affect app or messages
9. **Cleanup recommended** — delete unused webhooks to stay within 5 per app limit
10. **Project scoped** — webhook_id must belong to specified project_id
