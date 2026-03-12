# Create Webhook - Java Example

## Using sinch-sdk-java

```java
import com.sinch.sdk.SinchClient;
import com.sinch.sdk.domains.conversation.api.v1.WebhooksService;
import com.sinch.sdk.domains.conversation.models.v1.webhooks.*;
import com.sinch.sdk.models.ConversationRegion;
import java.util.Arrays;

public class CreateWebhookExample {
    public static void main(String[] args) {
        SinchClient sinchClient = SinchClient.builder()
                .setProjectId(System.getenv("SINCH_PROJECT_ID"))
                .setKeyId(System.getenv("SINCH_KEY_ID"))
                .setKeySecret(System.getenv("SINCH_KEY_SECRET"))
                .setConversationRegion(ConversationRegion.US)  // or EU, BR
                .build();

        try {
            WebhooksService webhooksService = sinchClient.conversation().v1().webhooks();

            // Build client credentials (optional OAuth2.0)
            ClientCredentials clientCredentials = ClientCredentials.builder()
                    .setClientId("your-oauth-client-id")
                    .setClientSecret("your-oauth-client-secret")
                    .setEndpoint("https://your-server.com/oauth2/token")
                    .setScope("webhooks")
                    .setTokenRequestType(TokenRequestType.BASIC)  // or FORM
                    .build();

            // Build webhook configuration
            Webhook webhookToCreate = Webhook.builder()
                    .setAppId("YOUR_APP_ID")
                    .setTarget("https://your-server.com/webhook")
                    .setTargetType(WebhookTargetType.HTTP)
                    .setTriggers(Arrays.asList(
                            WebhookTrigger.MESSAGE_INBOUND,
                            WebhookTrigger.MESSAGE_DELIVERY,
                            WebhookTrigger.EVENT_INBOUND
                    ))
                    .setSecret("your-webhook-secret-for-hmac")  // Optional
                    .setClientCredentials(clientCredentials)  // Optional
                    .build();

            // Create the webhook
            Webhook createdWebhook = webhooksService.create(webhookToCreate);

            System.out.println("Webhook created: " + createdWebhook);
            System.out.println("Webhook ID: " + createdWebhook.getId());

        } catch (Exception e) {
            System.err.println("Failed to create webhook: " + e.getMessage());
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

public class CreateWebhookRawOAuth {
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

    // Step 2: Create webhook
    public static JSONObject createWebhook(String projectId, String accessToken,
            JSONObject webhookData) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/webhooks",
                region, projectId);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + accessToken)
                .header("Content-Type", "application/json")
                .POST(BodyPublishers.ofString(webhookData.toString()))
                .build();

        HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Create webhook failed: " + response.statusCode() +
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

            JSONObject webhookData = new JSONObject()
                    .put("app_id", "YOUR_APP_ID")
                    .put("target", "https://your-server.com/webhook")
                    .put("target_type", "HTTP")
                    .put("triggers", new String[]{"MESSAGE_INBOUND", "MESSAGE_DELIVERY"})
                    .put("secret", "your-webhook-secret");

            JSONObject webhook = createWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    token,
                    webhookData
            );

            System.out.println("Webhook created: " + webhook.toString(2));

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
import java.net.http.HttpRequest.BodyPublishers;
import java.util.Base64;
import org.json.JSONObject;

public class CreateWebhookRawBasic {
    private static final HttpClient client = HttpClient.newHttpClient();

    public static JSONObject createWebhook(String projectId, String keyId, String keySecret,
            JSONObject webhookData) throws Exception {
        String region = System.getenv().getOrDefault("SINCH_REGION", "us");
        String url = String.format(
                "https://%s.conversation.api.sinch.com/v1/projects/%s/webhooks",
                region, projectId);

        String auth = Base64.getEncoder()
                .encodeToString((keyId + ":" + keySecret).getBytes());

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/json")
                .POST(BodyPublishers.ofString(webhookData.toString()))
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
            JSONObject webhookData = new JSONObject()
                    .put("app_id", "YOUR_APP_ID")
                    .put("target", "https://your-server.com/webhook")
                    .put("target_type", "HTTP")
                    .put("triggers", new String[]{"MESSAGE_INBOUND", "MESSAGE_DELIVERY"});

            JSONObject webhook = createWebhook(
                    System.getenv("SINCH_PROJECT_ID"),
                    System.getenv("SINCH_KEY_ID"),
                    System.getenv("SINCH_KEY_SECRET"),
                    webhookData
            );

            System.out.println("Webhook created: " + webhook.toString(2));

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

## Key Points

1. **Maximum 5 webhooks per app** — check existing webhooks before creating new ones
2. **HTTPS required** — target URL must use HTTPS protocol
3. **URL length limit** — maximum 742 characters for target URL
4. **Regional endpoint** — use `ConversationRegion.US`, `.EU`, or `.BR` matching your app
5. **Triggers enum** — use `WebhookTrigger` enum values (see available triggers in SKILL.md)
6. **OAuth2.0 configuration** — optional `ClientCredentials` for Sinch to authenticate when calling your webhook
7. **HMAC secret** — optional secret for callback signature verification
8. **Immediate activation** — callbacks start immediately after webhook creation
9. **Exception handling** — catch API exceptions for 400/403/500 errors
10. **Response includes webhook ID** — save this ID for update/delete operations
