# Money MCP operations

## Contents

- Connection
- Verification
- Tool surface
- Shared contracts
- Safe write patterns
- Errors

## Connection

- Server: `https://money.derose.app/mcp`
- Transport: Streamable HTTP
- Authentication: `Authorization: Bearer <API_KEY>`
- Credential source: `MONEY_MCP_TOKEN`
- Required key permission: `full_access`

Create the API key for the intended account in [PADMA Accounts](https://accounts.padm.am/accounts/current). Treat it as a password. Restart Codex after defining or changing the environment variable.

The plugin supplies this equivalent server configuration:

```json
{
  "mcpServers": {
    "money": {
      "type": "http",
      "url": "https://money.derose.app/mcp",
      "bearer_token_env_var": "MONEY_MCP_TOKEN"
    }
  }
}
```

## Verification

1. Call `get_business_context`.
2. Confirm the business, currency, timezone, capabilities, and limits.
3. Run a scoped read such as `list_accounts`.
4. Before the first write, preview the exact proposal and confirm it.

## Tool surface

### Context and reads

- `get_business_context`
- `list_accounts`
- `search_categories`
- `search_contacts`
- `search_movements`
- `get_movement`
- `search_recurrent_movements`
- `get_recurrent_movement`
- `search_plans`
- `get_plan`
- `search_automation_rules`
- `get_automation_rule`

Selection guidance:

- Use `search_movements` for audit, reconciliation, category review, finding a specific payment, duplicate checks, or explaining an aggregate.
- Use `get_movement` immediately before updating one movement.
- Use `category_subtotals` for category totals instead of summing a partially paginated movement page.
- Use `analyze_movements` for deterministic trends, variance, uncategorized items, aging, probable duplicates, outliers, and reporting-month mismatches.
- Use `search_plans` for forecast records and `search_recurrent_movements` for rules that create realized movements. Do not confuse the two.

### Analysis

- `category_subtotals`
- `analyze_movements`

### Writes

- `create_movement`, `update_movement`
- `create_category`, `update_category`
- `create_account`, `update_account`
- `create_recurrent_movement`, `update_recurrent_movement`
- `create_plan`, `update_plan`
- `create_automation_rule`, `update_automation_rule`

The implemented MCP does not expose deletion, batch mutation, import, contact mutation, or automatic bank-statement reconciliation.
It also does not expose dedicated account-balance, payable, receivable, budget, or projected-cash-flow tools. Never claim those outputs are directly available.

## Shared contracts

- IDs are integers and are resolved only inside the authenticated business.
- Monetary values use integer cents and always carry a currency. For example, ARS 1,000 is `100000` cents.
- `request_id` is a client-generated UUID for durable write idempotency.
- `expected_updated_at` is the latest ISO 8601 timestamp from a read and protects updates with optimistic concurrency.
- Search responses are cursor-paginated. Default and maximum page sizes may vary by tool.
- Related account, category, contact, agent, and target-account IDs must belong to the authenticated business.
- Records belonging to another business appear as `not_found` to avoid leaking their existence.

### Dates and reporting months

- Use `movement_at` for when money actually moved.
- Use `reconciled_at` for when a pending movement affected the account balance.
- Use `report_on` for the reporting month. Its `from` and `to` inputs include whole calendar months, even when day components are supplied.
- Movement searches default to a recent period; specify the intended range rather than assuming all history was searched.

### Movement states

- Pending movements count in reports but do not change account balances.
- Done movements count in reports and change balances on `movement_at`.
- Reconciled movements count in reports and change balances from `reconciled_at`.

## Safe write patterns

### Create

1. Search all referenced records and resolve their IDs.
2. Preview the complete proposed record.
3. Confirm the exact mutation.
4. Generate one UUID `request_id` and call the matching `create_*` tool.
5. Read the created record back or locate it with a scoped search.

Never create related records implicitly. If a requested category or account is missing, ask before creating it with its explicit tool.

### Update

1. Fetch the current record.
2. Preview only the requested field changes.
3. Confirm the exact mutation.
4. Generate a UUID `request_id` and pass the latest `updated_at` as `expected_updated_at`.
5. Call the matching `update_*` tool with only changed fields.
6. Refetch and verify.

If `expected_updated_at` is stale, do not overwrite. Refetch and reconcile with the current record.

### Retry

Reuse a `request_id` only when the prior response was uncertain and the payload is byte-for-byte equivalent in meaning. A different payload requires a new UUID. Never retry a timed-out write with a new request ID before checking whether it persisted.

## Errors

- `401`: token missing, invalid, expired, or unavailable to Codex. Check `MONEY_MCP_TOKEN` and restart.
- `403`: token lacks `full_access`, the business is disabled, the local user cannot authorize the action, or the client origin is rejected.
- `404` or `not_found`: the record is absent from the authenticated business; verify the ID through a scoped search.
- Validation error: correct the typed inputs; do not bypass schemas.
- Conflict: refetch the record or inspect idempotency input mismatch before retrying.
- Rate limit: wait for the indicated retry interval. Do not loop aggressively.
- No tools: verify that the URL ends in `/mcp`, the environment variable is available, and Codex was restarted.
- Unexpected business: remove or disable the connection and configure a key created for the correct account.

Source: [Money MCP documentation in Notion](https://app.notion.com/p/39e3160bddf28027a1fbec7a5102e070), fetched 2026-07-16, reconciled with the implemented Money MCP contract.
