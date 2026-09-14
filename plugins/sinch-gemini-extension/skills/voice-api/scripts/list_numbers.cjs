#!/usr/bin/env node
/*
 * EXECUTION TOOL — not a schema reference.
 * Run this to PERFORM a task (e.g. create a webhook, send a test message) when you do not
 * need to write application code. Do NOT copy its payload literals or logic into a new
 * codebase as if they were the API spec — load the authoritative developers.sinch.com doc
 * instead. See "Source of Truth" in this skill's SKILL.md.
 */
/**
 * List voice-capable numbers assigned to an application via Sinch Voice API.
 *
 * Usage:
 *   node list_numbers.cjs
 *
 * Environment variables (required):
 *   SINCH_APPLICATION_KEY    - Voice application key
 *   SINCH_APPLICATION_SECRET - Voice application secret
 */

var client = require("../common/voice_client.cjs");

async function main() {
  var appKey = client.getEnv("SINCH_APPLICATION_KEY");
  var appSecret = client.getEnv("SINCH_APPLICATION_SECRET");

  var url = client.CONFIG_BASE + "/v1/configuration/numbers";

  var result = await client.httpRequest(url, {
    method: "GET",
    headers: {
      Authorization: client.getAuthHeader(appKey, appSecret),
    },
  });

  console.log(JSON.stringify(result, null, 2));
}

main().catch(function (err) {
  console.error("Error:", err.message);
  process.exit(1);
});
