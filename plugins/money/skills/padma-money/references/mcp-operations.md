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
- Authentication: OAuth managed by the MCP client
- Client registration: Dynamic Client Registration (DCR)
- OAuth resource: `https://money.derose.app/mcp`

Connect Money when the client requests authorization, sign in, and authorize the intended account or accounts. The plugin does not require an API key or environment variable. Never paste authorization codes or access tokens into prompts, files, logs, URLs, or MCP arguments.

Do not configure a shared `oauth_client_id`, Client ID, or Client Secret. The
client discovers the Accounts `registration_endpoint`, registers its exact
callback as a public PKCE client, and receives its own `client_id`. Callback
wildcards such as `http://127.0.0.1/callback/*` are not supported.

The plugin supplies this equivalent server configuration:

```json
{
  "mcpServers": {
    "money": {
      "type": "http",
      "url": "https://money.derose.app/mcp"
    }
  }
}
```

### Codex

The plugin deliberately omits `oauth_client_id` so Codex uses DCR. If Money was
previously added manually with the shared static client, replace that entry:

```bash
codex mcp logout money
codex mcp remove money
codex mcp add money \
  --url https://money.derose.app/mcp \
  --oauth-resource https://money.derose.app/mcp
codex mcp login money --scopes openid,profile,account,money
```

### Claude Code

The plugin also omits advanced OAuth credentials for Claude Code. If the MCP
server must be added manually, use:

```bash
claude mcp add --transport http money https://money.derose.app/mcp
```

Then run `/mcp`, select Money, and complete authentication. Leave Client ID and
Client Secret empty so Claude Code can use DCR.

Accounts accepts up to 10 dynamic registrations per IP address every 60
seconds. On `429 Too Many Requests`, wait for the `Retry-After` interval instead
of looping.

## Verification

1. Call `list_businesses` with no arguments.
2. If it returns one Business, use it automatically. If it returns several, select only one explicitly identified by the user or ask which one to use.
3. Call `get_business_context` with the selected `business_id` when selection is required.
4. Confirm the business, currency, timezone, capabilities, and limits.
5. Run a scoped read such as `list_accounts`, preserving the same `business_id` throughout the workflow.
6. Before the first write, preview the exact proposal and confirm it.

## Tool surface

### Discovery

- `list_businesses`

It accepts no arguments and returns only locally usable Businesses authorized by OAuth, with `id`, `name`, `currency`, and `timezone`.

### Context and reads

- `get_business_context`
- `list_accounts`
- `search_categories`
- `search_contacts`
- `search_movements`
- `get_movement`
- `get_split`
- `search_recurrent_movements`
- `get_recurrent_movement`
- `search_plans`
- `get_plan`
- `search_automation_rules`
- `get_automation_rule`

Selection guidance:

- Use `search_movements` for audit, reconciliation, category review, finding a specific payment, duplicate checks, or explaining an aggregate.
- Use `get_movement` immediately before updating, deleting, prorating, or subdividing one movement. A non-null `split_id` identifies the split that owns a resulting movement.
- Use `get_split` to inspect the original snapshot, every resulting movement—including soft-deleted targets—and whether the split is currently revertible.
- Use `category_subtotals` for category totals instead of summing a partially paginated movement page.
- Use `analyze_movements` for deterministic trends, variance, uncategorized items, aging, probable duplicates, outliers, and reporting-month mismatches.
- Use `search_plans` for forecast records and `search_recurrent_movements` for rules that create realized movements. Do not confuse the two.

### Analysis

- `category_subtotals`
- `analyze_movements`

### Writes

- `create_movement`, `update_movement`, `delete_movement`
- `prorate_movement`, `subdivide_movement`, `revert_split`
- `create_category`, `update_category`
- `create_account`, `update_account`
- `create_recurrent_movement`, `update_recurrent_movement`
- `create_plan`, `update_plan`
- `create_automation_rule`, `update_automation_rule`

The implemented MCP exposes thirty-two tools: `list_businesses` plus thirty-one Business-contextual tools. `delete_movement` performs a recoverable soft delete. `revert_split` is the only restoration and physical-deletion operation: it atomically restores one split's original movement and removes all unchanged targets. The MCP does not expose general movement restoration or physical deletion, deletion of other record types, batch mutation, import, contact mutation, or automatic bank-statement reconciliation.
It also does not expose dedicated account-balance, payable, receivable, budget, or projected-cash-flow tools. Never claim those outputs are directly available.

## Shared contracts

- `business_id` is an optional integer on every tool except `list_businesses`. It selects from the OAuth-derived allowlist; it never grants access by itself.
- With one authorized Business, contextual tools select it automatically when `business_id` is omitted. With several, omission returns `business_required`.
- Use only IDs returned by `list_businesses`. An unknown or unauthorized selector returns `forbidden` without revealing whether another tenant exists.
- Record IDs are integers and are resolved only inside the selected Business.
- Monetary values use integer cents and always carry a currency. For example, ARS 1,000 is `100000` cents.
- `request_id` is a client-generated UUID for durable write idempotency.
- `expected_updated_at` is the latest ISO 8601 timestamp from a read and protects updates, movement deletion, proration, and subdivision with optimistic concurrency.
- `revert_split` requires the exact `expected_movements` list returned by `get_split`, containing every target `id` and `updated_at`. A changed, deleted, added, duplicated, or omitted target produces `conflict`.
- Search responses are cursor-paginated. Default and maximum page sizes may vary by tool.
- Related account, category, contact, agent, and target-account IDs must belong to the selected Business.
- Records belonging to another business appear as `not_found` to avoid leaking their existence.
- The rate limit is shared by the OAuth token across all its authorized Businesses.

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

### Delete a movement

1. Fetch the current movement immediately before proposing deletion.
2. Show the Business, movement ID, type, account, amount and currency, dates, category, and description.
3. Explain that `delete_movement` is a soft delete: normal reads stop returning the movement, while Money preserves its record and audit history.
4. Obtain explicit confirmation for that exact movement.
5. Generate a UUID `request_id` and call `delete_movement` with the movement ID and latest `updated_at` as `expected_updated_at`.
6. Verify that `get_movement` returns `not_found`, then report the returned `deleted_at` timestamp.

Do not use deletion as a substitute for correcting an amount, date, category, or other editable field. General restoration and physical deletion are not exposed; `revert_split` applies only to a complete, unchanged split.

### Prorate or subdivide a movement

Both operations replace the original movement with a new split. Obtain explicit confirmation after showing the complete result that will replace it.

For `prorate_movement`:

1. Fetch the movement immediately before writing and confirm it is neither a Transfer nor already part of a split.
2. Show the number of installments, their exact amounts, and their reporting months. The first uses the original `report_on`, later installments advance one month, and any cent remainder belongs to the last installment.
3. Generate a UUID `request_id` and call `prorate_movement` with the movement ID, latest `updated_at`, and `installments`.

For `subdivide_movement`:

1. Fetch the movement immediately before writing.
2. Show at least two positive integer-cent parts whose amounts exactly total the original. State every description, category, and agent override; omitted fields inherit from the original.
3. Resolve category and agent IDs inside the selected Business.
4. Generate a UUID `request_id` and call `subdivide_movement` with the movement ID, latest `updated_at`, and complete `parts`.

After either operation, use the returned split ID with `get_split` and verify the complete target list. Do not split a resulting movement again.

### Revert a split

1. Call `get_split` immediately before proposing the reversal.
2. Require `revertible: true`. Show the original movement that will be restored and every target that will be physically removed, including soft-deleted targets.
3. Obtain explicit confirmation for that exact split composition.
4. Generate a UUID `request_id` and call `revert_split` with the split ID and the exact target `id` and `updated_at` pairs returned by `get_split`.
5. Verify the restored movement with `get_movement`.

There is no `force` option. On `conflict`, stop, call `get_split` again, explain what changed, and request new confirmation. Never remove, add, or rewrite entries in `expected_movements` to bypass the conflict.

### Retry

Reuse a `request_id` only when the prior response was uncertain and the payload is byte-for-byte equivalent in meaning. A different payload requires a new UUID. Never retry a timed-out write with a new request ID before checking whether it persisted.

## Errors

- `401`: the OAuth session is missing, invalid, or expired. Reconnect Money and complete authorization.
- `403`: the OAuth session lacks the required access, the business is disabled, the user cannot authorize the action, or the client origin is rejected.
- `404` or `not_found`: the record is absent from the selected Business; verify the ID through a scoped search.
- `business_required`: more than one Business is authorized and a contextual tool omitted `business_id`; call `list_businesses`, select one, and retry.
- MCP `forbidden`: the requested `business_id` is not in the authorized allowlist or the local user cannot perform the action. Do not probe other IDs.
- Validation error: correct the typed inputs; do not bypass schemas.
- Conflict: refetch the record, or call `get_split` again for a reversal, and inspect any idempotency input mismatch before retrying.
- Rate limit: wait for the indicated retry interval. Do not loop aggressively.
- No tools: verify that the URL ends in `/mcp`, reconnect Money, complete OAuth authorization, and start a new task.
- Intended Business missing from `list_businesses`: reconnect Money and grant the corresponding account in OAuth.

Source: [Money MCP documentation in Notion](https://app.notion.com/p/39e3160bddf28027a1fbec7a5102e070), fetched 2026-07-16, reconciled with the implemented Money MCP contract. Authentication and multi-Business selection updated on 2026-07-21; split tool catalog updated on 2026-07-27.
