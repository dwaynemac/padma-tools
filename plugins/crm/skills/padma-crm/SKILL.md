---
name: padma-crm
description: Use PADMA CRM through its remote read-only MCP server to find authorized accounts, search contacts by name, PADMA ID, email, phone, or status, inspect account-scoped contact details, analyze persisted school monthly statistics, compare periods, and review lead funnels. Use for requests about CRM contacts, prospects, students, contact status, enrollment and dropout metrics, monthly school performance, or commercial funnels stored in PADMA CRM.
---

# Use PADMA CRM

Use the `crm` MCP server as the only execution path for CRM data. OAuth determines the account allowlist; `account_name` only selects one account from that authorized set.

## Prepare

1. Confirm that `crm` tools are available. Do not substitute browser automation, database access, or another integration when the MCP server is unavailable.
2. Call `list_accounts` first. Treat it as the authoritative list for the current OAuth session.
3. If one account is authorized, use it automatically. If several are authorized, select an account explicitly identified by the user or ask which one to use. Never infer an account from unrelated context.
4. Keep the selected `account_name` on every account-scoped call in the workflow.
5. Call `get_account_context` to obtain roles, valid contact statuses, capabilities, and current limits.
6. Read [references/mcp-operations.md](references/mcp-operations.md) for connection, selection, tool, pagination, and error contracts.
7. Read [references/contacts.md](references/contacts.md) for contact searches, detail handling, and privacy rules.
8. Read [references/monthly-statistics.md](references/monthly-statistics.md) before answering metric, comparison, trend, or funnel questions.

## Search contacts

1. Use `search_contacts` with the narrowest useful text and status filters.
2. Paginate when the requested scope exceeds one page. Do not present a truncated page as a complete result.
3. Use only returned `padma_id` values with `get_contact`; never invent or substitute an identifier.
4. Treat email, phone, visits, status, coefficient, and teacher information as personal data. Return only fields needed for the user's request.
5. State the selected account and material filters. Keep facts returned by CRM separate from interpretation.

## Analyze monthly statistics

1. Discover stable metric names with `list_monthly_stat_definitions`; do not invent a `stat_name` from a translated label.
2. Use `get_monthly_stats` for exact series and freshness, `compare_monthly_stats` for shared dashboard comparison semantics, and `get_lead_funnel` for funnel aggregation.
3. Preserve missing values as unknown. Never convert `value: null` into zero or calculate a missing statistic outside CRM.
4. Interpret rate values and deltas as percentages and percentage points according to the statistics reference.
5. State account, period, metric names, missing months, and freshness when they affect the answer.

## Protect authorization and scope

- Never ask the user to paste an OAuth authorization code or access token into a prompt.
- Never place OAuth credentials in files, URLs, logs, or MCP arguments. The client manages OAuth and DCR.
- Never treat an `account_name` supplied by the user as authorization. Use only an account returned by `list_accounts`.
- Do not switch accounts during a workflow unless the user explicitly asks.
- Do not combine contacts or statistics from different accounts unless the user explicitly requests a clearly separated comparison and each account is authorized.

## Respect read-only limits

- CRM exposes no write tools in this release. Do not claim to update contacts, statuses, or statistics.
- Do not emulate writes through browser automation or unrelated tools.
- Do not call missing-stat calculation paths or present derived values as persisted CRM statistics.
- If a requested operation is unsupported, explain the read-only boundary and offer the closest available read operation.
