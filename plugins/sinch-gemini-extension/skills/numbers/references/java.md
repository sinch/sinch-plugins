# Java - Numbers Code Generation

This reference provides Java patterns for fetching and managing Sinch active phone numbers using the Sinch SDK.

## Table of Contents
- [Core Service Implementation](#core-service-implementation)
- [Model Classes](#model-classes)
- [SDK Integration](#sdk-integration)
- [Error Handling](#error-handling)
- [Usage Examples](#usage-examples)

## Core Service Implementation

### NumberService Class (Using Sinch SDK)

```java
package com.sinch.numbers;

import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.numbers.models.v1.*;
import java.util.List;
import java.util.Optional;

public class NumberService {
    private final SinchClient sinchClient;
    private final SinchConfig config;

    public NumberService(SinchConfig config) {
        this.config = config;
        
        Configuration sdkConfig = Configuration.builder()
                .setProjectId(config.getProjectId())
                .setKeyId(config.getKeyId())
                .setKeySecret(config.getKeySecret())
                .build();
        
        this.sinchClient = new SinchClient(sdkConfig);
    }

    public List<ActiveNumber> loadNumbers(int pageSize) {
        try {
            var response = sinchClient.numbers().activeNumber().list(
                    ActiveNumberListRequest.builder()
                            .setProjectId(config.getProjectId())
                            .setPageSize(pageSize)
                            .build()
            );
            
            return response.getActiveNumbers();
        } catch (Exception e) {
            System.err.println("Failed to load numbers: " + e.getMessage());
            throw new NumberServiceException("Failed to load numbers", e);
        }
    }

    public List<ActiveNumber> loadNumbers() {
        return loadNumbers(100);
    }

    public Optional<ActiveNumber> getNumberByPhone(String phoneNumber) {
        try {
            var number = sinchClient.numbers().activeNumber().get(phoneNumber);
            return Optional.of(number);
        } catch (Exception e) {
            System.err.println("Failed to get number " + phoneNumber + ": " + e.getMessage());
            return Optional.empty();
        }
    }

    public SinchClient getClient() {
        return sinchClient;
    }
}
```

### Configuration Class

```java
package com.sinch.numbers;

public class SinchConfig {
    private final String projectId;
    private final String keyId;
    private final String keySecret;

    private SinchConfig(Builder builder) {
        this.projectId = builder.projectId;
        this.keyId = builder.keyId;
        this.keySecret = builder.keySecret;
    }

    public String getProjectId() {
        return projectId;
    }

    public String getKeyId() {
        return keyId;
    }

    public String getKeySecret() {
        return keySecret;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String projectId;
        private String keyId;
        private String keySecret;

        public Builder projectId(String projectId) {
            this.projectId = projectId;
            return this;
        }

        public Builder keyId(String keyId) {
            this.keyId = keyId;
            return this;
        }

        public Builder keySecret(String keySecret) {
            this.keySecret = keySecret;
            return this;
        }

        public SinchConfig build() {
            if (projectId == null || keyId == null || keySecret == null) {
                throw new IllegalStateException("All configuration fields are required");
            }
            return new SinchConfig(this);
        }
    }
}
```

## Model Classes

The Sinch SDK provides built-in model classes. You can use them directly:

```java
import com.sinch.sdk.domains.numbers.models.v1.ActiveNumber;
import com.sinch.sdk.domains.numbers.models.v1.NumberType;
import com.sinch.sdk.domains.numbers.models.v1.Capability;

// SDK models are already available, no need to define custom POJOs
```

### Optional: Custom Wrapper for Additional Functionality

```java
package com.sinch.numbers.model;

import com.sinch.sdk.domains.numbers.models.v1.ActiveNumber;

public class NumberInfo {
    private final ActiveNumber activeNumber;
    private boolean isSelected;

    public NumberInfo(ActiveNumber activeNumber) {
        this.activeNumber = activeNumber;
        this.isSelected = false;
    }

    public ActiveNumber getActiveNumber() {
        return activeNumber;
    }

    public String getPhoneNumber() {
        return activeNumber.getPhoneNumber();
    }

    public String getType() {
        return activeNumber.getType() != null ? activeNumber.getType().toString() : null;
    }

    public String getRegionCode() {
        return activeNumber.getRegionCode();
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    @Override
    public String toString() {
        return String.format("%s (%s, %s)", 
            getPhoneNumber(), 
            getType(), 
            getRegionCode()
        );
    }
}
```

## SDK Integration

### Simple Approach with SDK

```java
package com.sinch.numbers;

import com.sinch.sdk.SinchClient;
import com.sinch.sdk.models.Configuration;
import com.sinch.sdk.domains.numbers.models.v1.ActiveNumber;
import java.util.List;

public class NumberFetcher {
    
    public static List<ActiveNumber> getNumbers(
            String projectId, 
            String keyId, 
            String keySecret) {
        
        Configuration config = Configuration.builder()
                .setProjectId(projectId)
                .setKeyId(keyId)
                .setKeySecret(keySecret)
                .build();

        SinchClient sinch = new SinchClient(config);
        
        var response = sinch.numbers().activeNumber().list(
                ActiveNumberListRequest.builder()
                        .setProjectId(projectId)
                        .setPageSize(100)
                        .build()
        );
        
        return response.getActiveNumbers();
    }
}
```

### With Pagination

```java
import java.util.ArrayList;

public class NumberFetcherWithPagination {
    
    public static List<ActiveNumber> getAllNumbers(
            String projectId,
            String keyId,
            String keySecret) {
        
        Configuration config = Configuration.builder()
                .setProjectId(projectId)
                .setKeyId(keyId)
                .setKeySecret(keySecret)
                .build();

        SinchClient sinch = new SinchClient(config);
        List<ActiveNumber> allNumbers = new ArrayList<>();
        String pageToken = null;
        
        do {
            var requestBuilder = ActiveNumberListRequest.builder()
                    .setProjectId(projectId)
                    .setPageSize(100);
            
            if (pageToken != null) {
                requestBuilder.setPageToken(pageToken);
            }
            
            var response = sinch.numbers().activeNumber().list(requestBuilder.build());
            allNumbers.addAll(response.getActiveNumbers());
            pageToken = response.getNextPageToken().orElse(null);
            
        } while (pageToken != null);
        
        return allNumbers;
    }
}
```

### Using Spring RestTemplate (Alternative without SDK)

```java
package com.sinch.numbers;

import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;

public class NumberServiceSpring {
    private final SinchConfig config;
    private final RestTemplate restTemplate;

    public NumberServiceSpring(SinchConfig config) {
        this.config = config;
        this.restTemplate = new RestTemplate();
    }

    public List<ActiveNumber> loadNumbers(int pageSize) {
        String url = String.format(
            "https://numbers.api.sinch.com/v1/projects/%s/activeNumbers?pageSize=%d",
            config.getProjectId(), pageSize
        );

        HttpHeaders headers = createAuthHeaders();
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<ActiveNumbersResponse> response = restTemplate.exchange(
            url, 
            HttpMethod.GET, 
            entity, 
            ActiveNumbersResponse.class
        );

        return response.getBody().getActiveNumbers();
    }

    private HttpHeaders createAuthHeaders() {
        String credentials = config.getKeyId() + ":" + config.getKeySecret();
        String encodedCredentials = Base64.getEncoder()
            .encodeToString(credentials.getBytes(StandardCharsets.UTF_8));

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Basic " + encodedCredentials);
        headers.setContentType(MediaType.APPLICATION_JSON);
        return headers;
    }
}
```

## Error Handling

### Custom Exception Classes

```java
package com.sinch.numbers.exception;

public class NumberServiceException extends RuntimeException {
    private final Integer statusCode;
    private final String responseBody;

    public NumberServiceException(String message) {
        super(message);
        this.statusCode = null;
        this.responseBody = null;
    }

    public NumberServiceException(String message, Throwable cause) {
        super(message, cause);
        this.statusCode = null;
        this.responseBody = null;
    }

    public NumberServiceException(String message, int statusCode, String responseBody) {
        super(message);
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public Integer getStatusCode() {
        return statusCode;
    }

    public String getResponseBody() {
        return responseBody;
    }
}

public class NumberAuthException extends NumberServiceException {
    public NumberAuthException(String message) {
        super(message);
    }
}

public class NumberNotFoundException extends NumberServiceException {
    public NumberNotFoundException(String message) {
        super(message);
    }
}
```

### Service with Comprehensive Error Handling

```java
public List<ActiveNumber> loadNumbersWithErrorHandling(int pageSize) {
    try {
        var response = sinchClient.numbers().activeNumber().list(
                ActiveNumberListRequest.builder()
                        .setProjectId(config.getProjectId())
                        .setPageSize(pageSize)
                        .build()
        );
        
        return response.getActiveNumbers();
        
    } catch (com.sinch.sdk.core.exceptions.UnauthorizedException e) {
        throw new NumberAuthException("Authentication failed. Check your credentials.");
    } catch (com.sinch.sdk.core.exceptions.NotFoundException e) {
        throw new NumberNotFoundException("Project not found or no active numbers.");
    } catch (Exception e) {
        throw new NumberServiceException("Failed to fetch numbers: " + e.getMessage(), e);
    }
}
```

## Usage Examples

### Basic Usage

```java
package com.sinch.numbers.examples;

import com.sinch.numbers.NumberService;
import com.sinch.numbers.SinchConfig;
import com.sinch.sdk.domains.numbers.models.v1.ActiveNumber;
import java.util.List;

public class BasicExample {
    public static void main(String[] args) {
        SinchConfig config = SinchConfig.builder()
                .projectId("your-project-id")
                .keyId("your-key-id")
                .keySecret("your-key-secret")
                .build();

        NumberService service = new NumberService(config);
        List<ActiveNumber> numbers = service.loadNumbers();

        System.out.println("Found " + numbers.size() + " active numbers");
        
        for (ActiveNumber number : numbers) {
            System.out.printf("%s - %s (%s)%n", 
                number.getPhoneNumber(), 
                number.getType(), 
                number.getRegionCode()
            );
        }
    }
}
```

### With Environment Variables

```java
public class EnvExample {
    public static void main(String[] args) {
        String projectId = System.getenv("SINCH_PROJECT_ID");
        String keyId = System.getenv("SINCH_KEY_ID");
        String keySecret = System.getenv("SINCH_KEY_SECRET");

        if (projectId == null || keyId == null || keySecret == null) {
            System.err.println("Missing required environment variables");
            System.exit(1);
        }

        SinchConfig config = SinchConfig.builder()
                .projectId(projectId)
                .keyId(keyId)
                .keySecret(keySecret)
                .build();

        NumberService service = new NumberService(config);

        try {
            List<ActiveNumber> numbers = service.loadNumbers();
            System.out.println("Fetched " + numbers.size() + " numbers");
            
            numbers.forEach(number -> 
                System.out.println(number.getPhoneNumber())
            );
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

### Spring Boot REST Controller

```java
package com.sinch.numbers.controller;

import com.sinch.numbers.NumberService;
import com.sinch.sdk.domains.numbers.models.v1.ActiveNumber;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/numbers")
public class NumberController {
    
    private final NumberService numberService;

    @Autowired
    public NumberController(NumberService numberService) {
        this.numberService = numberService;
    }

    @GetMapping
    public ResponseEntity<NumberResponse> getNumbers(
            @RequestParam(defaultValue = "100") int pageSize,
            @RequestParam(required = false) String regionCode,
            @RequestParam(required = false) String type) {
        try {
            List<ActiveNumber> numbers = numberService.loadNumbers(pageSize);
            
            // Apply filters if provided
            if (regionCode != null) {
                numbers = numbers.stream()
                        .filter(n -> regionCode.equals(n.getRegionCode()))
                        .toList();
            }
            
            if (type != null) {
                numbers = numbers.stream()
                        .filter(n -> type.equals(n.getType().toString()))
                        .toList();
            }
            
            return ResponseEntity.ok(
                NumberResponse.success(numbers.size(), numbers)
            );
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                NumberResponse.error(e.getMessage())
            );
        }
    }

    @GetMapping("/{phoneNumber}")
    public ResponseEntity<SingleNumberResponse> getNumber(
            @PathVariable String phoneNumber) {
        try {
            var number = numberService.getNumberByPhone(phoneNumber);
            
            return number
                .map(n -> ResponseEntity.ok(SingleNumberResponse.success(n)))
                .orElse(ResponseEntity.notFound().build());
                
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                SingleNumberResponse.error(e.getMessage())
            );
        }
    }
}

// Response DTOs
record NumberResponse(
    boolean success, 
    int count, 
    List<ActiveNumber> numbers, 
    String error
) {
    static NumberResponse success(int count, List<ActiveNumber> numbers) {
        return new NumberResponse(true, count, numbers, null);
    }
    
    static NumberResponse error(String error) {
        return new NumberResponse(false, 0, null, error);
    }
}

record SingleNumberResponse(
    boolean success,
    ActiveNumber number,
    String error
) {
    static SingleNumberResponse success(ActiveNumber number) {
        return new SingleNumberResponse(true, number, null);
    }
    
    static SingleNumberResponse error(String error) {
        return new SingleNumberResponse(false, null, error);
    }
}
```

### Spring Boot Configuration Bean

```java
package com.sinch.numbers.config;

import com.sinch.numbers.NumberService;
import com.sinch.numbers.SinchConfig;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SinchConfiguration {
    
    @Value("${sinch.project-id}")
    private String projectId;
    
    @Value("${sinch.key-id}")
    private String keyId;
    
    @Value("${sinch.key-secret}")
    private String keySecret;

    @Bean
    public SinchConfig sinchConfig() {
        return SinchConfig.builder()
                .projectId(projectId)
                .keyId(keyId)
                .keySecret(keySecret)
                .build();
    }

    @Bean
    public NumberService numberService(SinchConfig config) {
        return new NumberService(config);
    }
}
```

### CLI Application

```java
package com.sinch.numbers.cli;

import com.sinch.numbers.NumberService;
import com.sinch.numbers.SinchConfig;
import com.sinch.sdk.domains.numbers.models.v1.ActiveNumber;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import java.io.File;
import java.util.List;

public class NumberCLI {
    
    public static void main(String[] args) {
        if (args.length < 3) {
            System.err.println("Usage: java NumberCLI <project-id> <key-id> <key-secret> [output-file]");
            System.exit(1);
        }

        String projectId = args[0];
        String keyId = args[1];
        String keySecret = args[2];
        String outputFile = args.length > 3 ? args[3] : null;

        try {
            SinchConfig config = SinchConfig.builder()
                    .projectId(projectId)
                    .keyId(keyId)
                    .keySecret(keySecret)
                    .build();

            NumberService service = new NumberService(config);
            
            System.err.println("Fetching active numbers...");
            List<ActiveNumber> numbers = service.loadNumbers();
            System.err.println("Found " + numbers.size() + " numbers");

            ObjectMapper mapper = new ObjectMapper()
                    .enable(SerializationFeature.INDENT_OUTPUT);

            if (outputFile != null) {
                mapper.writeValue(new File(outputFile), numbers);
                System.err.println("Saved to " + outputFile);
            } else {
                System.out.println(mapper.writeValueAsString(numbers));
            }

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
```

### Maven Dependencies

Add these dependencies to your `pom.xml`:

```xml
<dependencies>
    <!-- Sinch SDK -->
    <dependency>
        <groupId>com.sinch.sdk</groupId>
        <artifactId>sinch-sdk-java</artifactId>
        <version>1.0.0</version>
    </dependency>
    
    <!-- For JSON processing --> <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.15.0</version>
    </dependency>
</dependencies>
```
