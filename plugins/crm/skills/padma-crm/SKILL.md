---
name: padma-crm
description: Use PADMA CRM through its remote MCP server to find authorized accounts, discover contact tags, marketing methods, and saved lists, search contacts with account-scoped identity, relationship, activity, and list filters, inspect contact details, Learn activity summaries, and history, add contact comments, analyze persisted school monthly statistics, compare periods, and review lead funnels. Use for requests about CRM contacts, prospects, students, Learn activity or churn risk, comments, communication history, segmentation, contact status, enrollment and dropout metrics, monthly school performance, or commercial funnels stored in PADMA CRM.
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
7. Read [references/objects-and-attributes.md](references/objects-and-attributes.md) for the product meaning of CRM objects.
8. Read [references/contacts.md](references/contacts.md) for contact searches, detail handling, and privacy rules.
9. Read [references/learn-activity-summary.md](references/learn-activity-summary.md) before interpreting Learn activity deltas, flags, timestamps, or churn risk.
10. Read [references/monthly-statistics.md](references/monthly-statistics.md) before answering metric, comparison, trend, or funnel questions.

## Search contacts

1. Use `search_contacts` with the narrowest useful identity, relationship, activity, and date filters.
2. Before filtering by tags, marketing methods, or saved lists, call `list_tags`, `list_marketing_methods`, or `list_contact_lists` in the selected account. Use only IDs returned by those current calls.
3. Use `intersect_list_ids` for membership in every selected list, `union_list_ids` for membership in any selected list, and `not_in_list_ids` for exclusions.
4. Paginate when the requested scope exceeds one page. Do not present a truncated page as a complete result or reuse a cursor after changing filters.
5. Use only returned `padma_id` values with `get_contact`, `get_contact_learn_activity_summary`, or `get_contact_history`; never invent or substitute an identifier.
6. Treat email, phone, visits, status, coefficient, teacher, tags, and list membership as personal data. Return only fields needed for the user's request.
7. State the selected account and material filters. Keep facts returned by CRM separate from interpretation.

## Inspect Learn activity

1. Resolve the contact in the selected account with a current `padma_id`.
2. Call `get_contact_learn_activity_summary` with `account_name` and `padma_id`.
3. Interpret the returned values using [references/learn-activity-summary.md](references/learn-activity-summary.md). In particular, treat deltas as ratios rather than percentage-point changes.
4. Report only the returned activity, attendance, cancellation, and churn-risk signals. The summary is `null` when Learn has not calculated it.
5. Treat the values as a snapshot calculated by Learn, not a prediction or diagnosis made by the agent.

## Analyze monthly statistics

1. Discover stable metric names with `list_monthly_stat_definitions`; do not invent a `stat_name` from a translated label.
2. Use `get_monthly_stats` for exact series and freshness, `compare_monthly_stats` for shared dashboard comparison semantics, and `get_lead_funnel` for funnel aggregation.
3. Preserve missing absolute values as unknown. Never convert `value: null` into zero or calculate a missing absolute statistic outside CRM.
4. Do not request deprecated rate `stat_name` values. Derive a requested percentage from the documented absolute numerator and denominator only when both are present and the denominator is greater than zero.
5. State account, period, metric names, missing months, and freshness when they affect the answer.

## Add a contact comment

1. Use `add_contact_comment` only when the user explicitly asks to record a comment and supplies or approves the exact text.
2. Resolve the selected account and contact first. Use a current `padma_id` from `search_contacts`, and disambiguate same-name contacts before writing.
3. State the selected account and contact before the write when identity could be ambiguous. Never send a comment to a merely similar contact.
4. Call `add_contact_comment` once with `account_name`, `padma_id`, and `observations`. The server records the authenticated username and current time; the comment is visible to the selected account.
5. Treat the tool as non-idempotent. If the result is uncertain, inspect `get_contact_history` before retrying so the same comment is not created twice.
6. Report the created comment and contact. Do not claim success from intent or an OAuth login alone.

## Protect authorization and scope

- Never ask the user to paste an OAuth authorization code or access token into a prompt.
- Never place OAuth credentials in files, URLs, logs, or MCP arguments. The client manages OAuth and DCR.
- Never treat an `account_name` supplied by the user as authorization. Use only an account returned by `list_accounts`.
- Do not switch accounts during a workflow unless the user explicitly asks.
- Do not combine contacts or statistics from different accounts unless the user explicitly requests a clearly separated comparison and each account is authorized.

## Respect write limits

- CRM can add contact comments. It cannot update contacts, statuses, or statistics.
- Do not emulate writes through browser automation or unrelated tools.
- Do not call missing-stat calculation paths or present derived values as persisted CRM statistics.
- If a requested operation is unsupported, explain the boundary and offer the closest available operation.
