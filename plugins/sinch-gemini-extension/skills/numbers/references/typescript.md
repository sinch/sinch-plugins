# TypeScript - Numbers Code Generation

This reference provides TypeScript patterns for fetching and managing Sinch active phone numbers using the Sinch SDK.

## Table of Contents
- [Core Service Implementation](#core-service-implementation)
- [Type Definitions](#type-definitions)
- [SDK Integration](#sdk-integration)
- [Error Handling](#error-handling)
- [Usage Examples](#usage-examples)

## Core Service Implementation

### NumberService Class (Using Sinch SDK)

```typescript
import { SinchClient } from '@sinch/sdk-core';
import type { Numbers } from '@sinch/sdk-core';

export interface SinchConfig {
  projectId: string;
  keyId: string;
  keySecret: string;
}

export type ActiveNumber = Numbers.ActiveNumber;

export class NumberService {
  private client: SinchClient;
  private config: SinchConfig;

  constructor(config: SinchConfig) {
    this.config = config;
    this.client = new SinchClient({
      projectId: config.projectId,
      keyId: config.keyId,
      keySecret: config.keySecret,
    });
  }

  async loadNumbers(pageSize: number = 100): Promise<ActiveNumber[]> {
    try {
      const response = await this.client.numbers.activeNumber.list({
        projectId: this.config.projectId,
        pageSize,
      });

      return response.activeNumbers || [];
    } catch (error) {
      console.error('Failed to load numbers:', error);
      throw error;
    }
  }

  async getNumberByPhone(phoneNumber: string): Promise<ActiveNumber | null> {
    try {
      const number = await this.client.numbers.activeNumber.get({
        projectId: this.config.projectId,
        phoneNumber,
      });
      return number;
    } catch (error) {
      console.error(`Failed to get number ${phoneNumber}:`, error);
      return null;
    }
  }

  getSelectedNumber(storage: Storage, key: string = 'selectedNumber'): string | null {
    return storage.getItem(key);
  }

  setSelectedNumber(storage: Storage, phoneNumber: string, key: string = 'selectedNumber'): void {
    storage.setItem(key, phoneNumber);
  }

  clearSelectedNumber(storage: Storage, key: string = 'selectedNumber'): void {
    storage.removeItem(key);
  }
}
```

## Type Definitions

### Complete Type Definitions

```typescript
// types/number.types.ts
import type { Numbers } from '@sinch/sdk-core';

export type ActiveNumber = Numbers.ActiveNumber;

export type NumberCapability = 'SMS' | 'VOICE';

export type NumberType = 'LOCAL' | 'MOBILE' | 'TOLL_FREE';

export interface SinchApiConfig {
  projectId: string;
  keyId: string;
  keySecret: string;
}

export interface GetNumbersOptions {
  pageSize?: number;
  pageToken?: string;
  regionCode?: string;
  type?: NumberType;
}

export interface NumberWithSelection extends ActiveNumber {
  isSelected?: boolean;
}
```

## SDK Integration

### Simple Fetch Function

```typescript
import { SinchClient } from '@sinch/sdk-core';
import type { Numbers } from '@sinch/sdk-core';

async function getNumbers(config: SinchConfig): Promise<Numbers.ActiveNumber[]> {
  const sinch = new SinchClient({
    projectId: config.projectId,
    keyId: config.keyId,
    keySecret: config.keySecret,
  });

  const response = await sinch.numbers.activeNumber.list({
    projectId: config.projectId,
    pageSize: 100,
  });

  return response.activeNumbers || [];
}
```

### With Pagination

```typescript
async function getAllNumbers(config: SinchConfig): Promise<Numbers.ActiveNumber[]> {
  const sinch = new SinchClient({
    projectId: config.projectId,
    keyId: config.keyId,
    keySecret: config.keySecret,
  });

  let allNumbers: Numbers.ActiveNumber[] = [];
  let pageToken: string | undefined;

  do {
    const response = await sinch.numbers.activeNumber.list({
      projectId: config.projectId,
      pageSize: 100,
      pageToken,
    });

    allNumbers = allNumbers.concat(response.activeNumbers || []);
    pageToken = response.nextPageToken;
  } while (pageToken);

  return allNumbers;
}
```

### With Filtering

```typescript
async function getNumbersByRegion(
  config: SinchConfig,
  regionCode: string
): Promise<Numbers.ActiveNumber[]> {
  const sinch = new SinchClient(config);

  const response = await sinch.numbers.activeNumber.list({
    projectId: config.projectId,
    regionCode,
    pageSize: 100,
  });

  return response.activeNumbers || [];
}

async function getNumbersByType(
  config: SinchConfig,
  type: NumberType
): Promise<Numbers.ActiveNumber[]> {
  const sinch = new SinchClient(config);

  const response = await sinch.numbers.activeNumber.list({
    projectId: config.projectId,
    type,
    pageSize: 100,
  });

  return response.activeNumbers || [];
}
```

## Error Handling

### Robust Error Handling Pattern

```typescript
class NumberServiceError extends Error {
  constructor(
    message: string,
    public code?: string,
    public details?: any
  ) {
    super(message);
    this.name = 'NumberServiceError';
  }
}

async function getNumbersWithErrorHandling(
  config: SinchConfig
): Promise<Numbers.ActiveNumber[]> {
  try {
    const sinch = new SinchClient(config);
    
    const response = await sinch.numbers.activeNumber.list({
      projectId: config.projectId,
      pageSize: 100,
    });

    return response.activeNumbers || [];
  } catch (error: any) {
    if (error.code === 'ENOTFOUND') {
      throw new NumberServiceError(
        'Network error: Unable to reach Sinch API',
        'NETWORK_ERROR'
      );
    }
    
    if (error.statusCode === 401) {
      throw new NumberServiceError(
        'Authentication failed: Invalid credentials',
        'AUTH_ERROR'
      );
    }

    if (error.statusCode === 404) {
      throw new NumberServiceError(
        'Project not found or no active numbers',
        'NOT_FOUND'
      );
    }

    throw new NumberServiceError(
      `Failed to fetch numbers: ${error.message}`,
      'UNKNOWN_ERROR',
      error
    );
  }
}
```

## Usage Examples

### Basic Usage

```typescript
import { SinchClient } from '@sinch/sdk-core';

// Initialize service
const config: SinchConfig = {
  projectId: process.env.SINCH_PROJECT_ID!,
  keyId: process.env.SINCH_KEY_ID!,
  keySecret: process.env.SINCH_KEY_SECRET!,
};

const numberService = new NumberService(config);

// Fetch numbers
const numbers = await numberService.loadNumbers();
console.log(`Found ${numbers.length} active numbers`);

// Display number info
numbers.forEach(number => {
  console.log(`${number.phoneNumber} - ${number.type} (${number.regionCode})`);
  console.log(`  Capabilities: ${number.capability?.join(', ')}`);
});
```

### With State Management (React Hook)

```typescript
import { useState, useEffect } from 'react';
import type { Numbers } from '@sinch/sdk-core';

function useNumbers(config: SinchConfig) {
  const [numbers, setNumbers] = useState<Numbers.ActiveNumber[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const service = new NumberService(config);
    
    service.loadNumbers()
      .then(setNumbers)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [config]);

  return { numbers, loading, error };
}

// Usage in component
function NumberList() {
  const config = {
    projectId: process.env.REACT_APP_SINCH_PROJECT_ID!,
    keyId: process.env.REACT_APP_SINCH_KEY_ID!,
    keySecret: process.env.REACT_APP_SINCH_KEY_SECRET!,
  };

  const { numbers, loading, error } = useNumbers(config);

  if (loading) return <div>Loading numbers...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <ul>
      {numbers.map(number => (
        <li key={number.phoneNumber}>
          {number.phoneNumber} - {number.type} ({number.regionCode})
        </li>
      ))}
    </ul>
  );
}
```

### Advanced React Hook with Selection

```typescript
import { useState, useEffect, useCallback } from 'react';

function useNumbersWithSelection(config: SinchConfig) {
  const [numbers, setNumbers] = useState<Numbers.ActiveNumber[]>([]);
  const [selectedNumber, setSelectedNumber] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const service = new NumberService(config);
    
    // Load numbers
    service.loadNumbers()
      .then(setNumbers)
      .catch(setError)
      .finally(() => setLoading(false));

    // Load saved selection
    const saved = service.getSelectedNumber(localStorage);
    if (saved) setSelectedNumber(saved);
  }, [config]);

  const selectNumber = useCallback((phoneNumber: string) => {
    const service = new NumberService(config);
    service.setSelectedNumber(localStorage, phoneNumber);
    setSelectedNumber(phoneNumber);
  }, [config]);

  const clearSelection = useCallback(() => {
    const service = new NumberService(config);
    service.clearSelectedNumber(localStorage);
    setSelectedNumber(null);
  }, [config]);

  return { 
    numbers, 
    selectedNumber, 
    loading, 
    error,
    selectNumber,
    clearSelection,
  };
}
```

### Node.js Script

```typescript
// get-numbers.ts
import { SinchClient } from '@sinch/sdk-core';

async function main() {
  const config = {
    projectId: process.env.SINCH_PROJECT_ID!,
    keyId: process.env.SINCH_KEY_ID!,
    keySecret: process.env.SINCH_KEY_SECRET!,
  };

  const sinch = new SinchClient(config);

  console.log('Fetching active numbers...');
  
  const response = await sinch.numbers.activeNumber.list({
    projectId: config.projectId,
  });

  const numbers = response.activeNumbers || [];
  
  console.log(`Found ${numbers.length} active numbers:\n`);
  console.log(JSON.stringify(numbers, null, 2));
}

main().catch(console.error);
```

### Express.js API Endpoint

```typescript
import express from 'express';
import { SinchClient } from '@sinch/sdk-core';

const app = express();
const sinch = new SinchClient({
  projectId: process.env.SINCH_PROJECT_ID!,
  keyId: process.env.SINCH_KEY_ID!,
  keySecret: process.env.SINCH_KEY_SECRET!,
});

app.get('/api/numbers', async (req, res) => {
  try {
    const { regionCode, type } = req.query;

    const response = await sinch.numbers.activeNumber.list({
      projectId: process.env.SINCH_PROJECT_ID!,
      regionCode: regionCode as string,
      type: type as any,
      pageSize: 100,
    });

    res.json({
      success: true,
      count: response.activeNumbers?.length || 0,
      numbers: response.activeNumbers || [],
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

app.listen(3000, () => {
  console.log('API server running on port 3000');
});
```
