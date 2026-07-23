# CRM MCP operations

## Connection and OAuth

The plugin configures the `crm` Streamable HTTP MCP server at `https://crm.derose.app/mcp`. The client discovers PADMA Accounts as the authorization server, registers a public client through Dynamic Client Registration, and uses Authorization Code with PKCE. Do not configure a shared client secret.

The grant requires `openid profile account crm`, and the token audience must exactly match the MCP URL including scheme, hostname, and `/mcp`. A completed login is not proof that the integration works; verify it with `list_accounts` and at least one account-scoped tool call.

The CRM hostname selects the OAuth issuer and resource. It does not restrict authorized accounts by brand.

## Account selection

1. Call `list_accounts` before using account-scoped tools.
2. Select by stable `account_name`; database IDs are not part of the public contract.
3. Omit `account_name` only when one account is authorized. Pass it consistently once selected.
4. With several authorized accounts, ask the user when their request does not identify one unambiguously.
5. Call `get_account_context` after selection to inspect roles, valid statuses, read/write capabilities, and limits.

## Tools

| Tool | Main input | Use |
|---|---|---|
| `list_accounts` | none | Discover authorized accounts, brands, and grant roles. |
| `get_account_context` | optional `account_name` | Get selected account, user, roles, statuses, capabilities, and limits. |
| `list_tags` | optional `account_name` | Discover account tag IDs and names for `tag_ids`. |
| `list_marketing_methods` | optional `account_name` | Discover active account marketing method IDs and values. |
| `list_contact_lists` | optional `account_name` | Discover saved contact-list IDs and names. |
| `search_contacts` | optional account, filters, `page_size`, `cursor` | Search account-scoped contact summaries using identity, relationship, activity, date, tag, marketing, and list filters. |
| `get_contact` | optional `account_name`, required `padma_id` | Read one account-scoped contact detail. |
| `get_contact_history` | optional account, required `padma_id`; optional `page_size`, `cursor` | Read the contact activity feed, newest entry first. |
| `add_contact_comment` | optional account, required `padma_id` and `observations` | Add an account-visible follow-up comment as the authenticated user. |
| `list_monthly_stat_definitions` | optional `account_name` | Discover stable metric names, localized metadata, types, and availability. |
| `get_monthly_stats` | `stat_names`; optional account and month range | Read dense persisted monthly series. |
| `compare_monthly_stats` | `stat_names`; optional account and month | Compare current, previous, and prior-three-month baselines. |
| `get_lead_funnel` | optional account and month range | Aggregate persisted funnel stages and transitions. |

## Contact-comment writes

- Resolve the contact in the selected account before calling `add_contact_comment`.
- Pass only `account_name`, `padma_id`, and the exact approved comment text as `observations`.
- The server assigns the authenticated username, current timestamp, `FollowUp` type, and account visibility.
- Each successful call creates a new comment. It is not idempotent.
- On an uncertain result, inspect `get_contact_history` before retrying.
- CRM exposes no other write operation in this release.

## Pagination and limits

- Contact pages default to 50 and accept at most 200 records.
- A returned contact cursor is signed and bound to its account and filters. Reuse it only for the next page of the identical search.
- Contact-history pages use the same 1–200 page-size limit. Reuse their signed cursor only with the same account, `padma_id`, and page size.
- Explicit contact-search dates use strict `YYYY-MM-DD` values.
- `status` accepts one value; `statuses` accepts several. Do not send both.
- Call the matching discovery tool before using `tag_ids`, `marketing_method_ids`, `intersect_list_ids`, `union_list_ids`, or `not_in_list_ids`. IDs from another account are rejected.
- Monthly series default to 12 months ending with the current month and accept at most 36 months.
- Statistics tools accept 1–20 supported `stat_names` per call.
- Month strings are strict `YYYY-MM` values.

## Error handling

Tool-level domain errors return `isError: true` with a stable code:

- `account_required`: select an account returned by `list_accounts`.
- `forbidden`: do not retry with invented account names; refresh authorization and account discovery.
- `not_found`: confirm the current account and identifier.
- `validation_failed`: correct names, dates, statuses, cursor, or other input.
- `limit_exceeded`: narrow the page, date range, or metric list.
- `internal_error`: report the correlation ID and avoid blind retries.

HTTP authentication and availability errors have different recovery:

- `401`: reconnect OAuth; verify the exact MCP resource URL.
- `403`: request the `crm` scope or authorize an enabled account.
- `429`: wait for `Retry-After` before retrying.
- `503`: Accounts could not validate the token; retry later without treating it as invalid credentials.
