# Get Webhook - Java Example

## Using sinch-sdk-java

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.domains.conversation.api.v1.WebhooksService;
import com.sinch.sdk.domains.conversation.models.v1.webhooks.*;
import com.sinch.sdk.models.ConversationRegion;

public class GetWebhookExample {
    public static void main(String[] args) {
        SinchClient sinchClient = SinchClient.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .setConversationRegion(ConversationRegion.US)  // or EU, BR
                .build();

        try {
            WebhooksService webhooksService = sinchClient.conversation().v1().webhooks();

            // Get webhook by ID
            Webhook webhook = webhooksService.get("YOUR_WEBHOOK_ID");

            System.out.println("Webhook: " + webhook);
            System.out.println("ID: " + webhook.getId());
            System.out.println("Target: " + webhook.getTarget());
            System.out.println("Triggers: " + webhook.getTriggers());
            System.out.println("App ID: " + webhook.getAppId());

        } catch (Exception e) {
            System.err.println("Failed to get webhook: " + e.getMessage());
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

public class GetWebhookRawOAuth {
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

    // Step 2: Get webhook
    public static JSONObject getWebhook(String projectId, String webhookId,
            String accessToken) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/webhooks/%s",
                region, projectId, webhookId);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + accessToken)
                .header("Content-Type", "application/json")
                .GET()
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Get webhook failed: " + response.statusCode() +
                    " " + response.body());
        }

        return new JSONObject(response.body());
    }

    // Usage
    public static void main(String[] args) {
        try {
            String token = getAccessToken(
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET")
            );

            JSONObject webhook = getWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_WEBHOOK_ID",
                    token
            );

            System.out.println("Webhook: " + webhook.toString(2));

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
import org.json.JSONObject;

public class GetWebhookRawBasic {
    private static final HttpClient client = HttpClient.newHttpClient();

    public static JSONObject getWebhook(String projectId, String webhookId,
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
                .GET()
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Failed: " + response.statusCode() + " " + response.body());
        }

        return new JSONObject(response.body());
    }

    // Usage
    public static void main(String[] args) {
        try {
            JSONObject webhook = getWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    "YOUR_WEBHOOK_ID",
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET")
            );

            System.out.println("Webhook: " + webhook.toString(2));

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Key Points

1. **Webhook ID required** — use the ID returned from create or list operations
2. **Project scoped** — webhook_id must belong to specified project_id
3. **Regional endpoint** — use `ConversationRegion.US`, `.EU`, or `.BR` matching your app
4. **Full webhook details** — returns complete configuration including masked secret
5. **Exception handling** — catch API exceptions for 404 if webhook not found, 403 for permission errors
6. **Includes app_id** — response shows which app the webhook belongs to
7. **Client credentials included** — OAuth2.0 config (if set) returned with client_secret masked
8. **Use for verification** — check webhook configuration before update
9. **Lightweight operation** — safe to call frequently for monitoring
10. **Active webhooks only** — cannot retrieve deleted webhooks
