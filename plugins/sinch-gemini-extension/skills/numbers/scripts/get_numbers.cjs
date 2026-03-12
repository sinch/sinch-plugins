#!/usr/bin/env node

const fs = require('fs');

async function getSenders(projectId, keyId, keySecret, pageSize = 100) {
    const baseUrl = 'https://numbers.api.sinch.com/v1';
    const url = `${baseUrl}/projects/${projectId}/activeNumbers?pageSize=${pageSize}`;

    const credentials = Buffer.from(`${keyId}:${keySecret}`).toString('base64');

    try {
        const response = await fetch(url, {
            headers: {
                'Authorization': `Basic ${credentials}`,
                'Content-Type': 'application/json',
            },
        });

        if (!response.ok) {
            const errorText = await response.text();
            console.error(`HTTP Error: ${response.status}`);
            console.error(`Response: ${errorText}`);
            process.exit(1);
        }

        const data = await response.json();
        const activeNumbers = data.activeNumbers || [];

        console.log(`Successfully fetched ${activeNumbers.length} senders`);
        return activeNumbers;
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
}

function parseArgs() {
    const args = process.argv.slice(2);
    const options = {
        projectId: process.env.SINCH_PROJECT_ID,
        keyId: process.env.SINCH_KEY_ID,
        keySecret: process.env.SINCH_KEY_SECRET,
        pageSize: 100,
        output: null,
    };

    for (let i = 0; i < args.length; i++) {
        switch (args[i]) {
            case '--project-id':
                options.projectId = args[++i];
                break;
            case '--key-id':
                options.keyId = args[++i];
                break;
            case '--key-secret':
                options.keySecret = args[++i];
                break;
            case '--page-size':
                options.pageSize = parseInt(args[++i], 10);
                break;
            case '--output':
                options.output = args[++i];
                break;
            case '--help':
            case '-h':
                console.log(`
Usage: node get_numbers.cjs [options]

Options:
  --project-id <id>     Sinch project ID
  --key-id <id>         Sinch API key ID
  --key-secret <secret> Sinch API key secret
  --page-size <number>  Page size (default: 100)
  --output <file>       Output file path (JSON)
  --help, -h            Show this help message

Environment Variables:
  SINCH_PROJECT_ID      Alternative to --project-id
  SINCH_KEY_ID          Alternative to --key-id
  SINCH_KEY_SECRET      Alternative to --key-secret

Examples:
  node get_numbers.cjs --project-id abc123 --key-id key --key-secret secret
  node get_numbers.cjs --output numbers.json
        `);
                process.exit(0);
                break;
        }
    }

    return options;
}

async function main() {
    const options = parseArgs();

    if (!options.projectId || !options.keyId || !options.keySecret) {
        console.error('Error: Missing required credentials');
        console.error('Provide via flags or environment variables:');
        console.error('  --project-id or SINCH_PROJECT_ID');
        console.error('  --key-id or SINCH_KEY_ID');
        console.error('  --key-secret or SINCH_KEY_SECRET');
        console.error('\nUse --help for more information');
        process.exit(1);
    }

    const senders = await getSenders(
        options.projectId,
        options.keyId,
        options.keySecret,
        options.pageSize
    );

    const output = JSON.stringify(senders, null, 2);

    if (options.output) {
        fs.writeFileSync(options.output, output);
        console.log(`Saved to ${options.output}`);
    } else {
        console.log('\nActive Senders:');
        console.log(output);
    }
}

if (require.main === module) {
    main().catch(error => {
        console.error('Fatal error:', error.message);
        process.exit(1);
    });
}

module.exports = { getSenders };
