---
name: padma-crm
description: Use PADMA CRM through its remote MCP server to find authorized accounts, discover contact metadata, search or create account-scoped contacts, retrieve saved contact lists with their configured properties, inspect or add contact properties, read Learn activity summaries and history, record communications and comments, analyze persisted school monthly statistics, compare periods, and review lead funnels. Use for requests about CRM contacts, prospects, students, saved lists, custom properties, Learn activity or churn risk, comments, communications, segmentation, contact status, enrollment and dropout metrics, monthly school performance, or commercial funnels stored in PADMA CRM.
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

1. Use `search_contacts` with the narrowest useful identity, relationship, activity, and date filters. For birthdays, use `birthday_day` and `birthday_month`; add `birthday_year` only when the birth year must also match, or omit the day to search a whole birthday month.
2. Before filtering by tags, marketing methods, or saved lists, call `list_tags`, `list_marketing_methods`, or `list_contact_lists` in the selected account. Use only IDs returned by those current calls.
3. Use `intersect_list_ids` for membership in every selected list, `union_list_ids` for membership in any selected list, and `not_in_list_ids` for exclusions.
4. Paginate when the requested scope exceeds one page. Do not present a truncated page as a complete result or reuse a cursor after changing filters.
5. Use only returned `padma_id` values with `get_contact`, `get_contact_learn_activity_summary`, or `get_contact_history`; never invent or substitute an identifier.
6. Treat email, phone, visits, status, coefficient, teacher, tags, and list membership as personal data. Return only fields needed for the user's request.
7. State the selected account and material filters. Keep facts returned by CRM separate from interpretation.

## Retrieve a saved contact list

1. Call `list_contact_lists` in the selected account and resolve the requested list to a current `list_id`.
2. Call `get_contact_list` when the user wants the contacts produced by that saved list. Do not recreate it with `search_contacts`: CRM applies the list's persisted filters, ordering, and membership semantics.
3. Do not send property selectors. The saved list controls projection through its configured UI columns, and every returned contact includes a `properties` array even when it is empty.
4. Use `list.columns` to report the saved configuration and `list.property_selection` to explain which system property types and custom definitions CRM projected. Computed, operational, and stale columns can remain in `columns` without producing properties.
5. Paginate with `next_cursor` until the requested scope is complete. Reuse the cursor only with the same account, list ID, and page size.

## Inspect contact properties

1. Without property selectors, preserve the compact default projection from `search_contacts` and `get_contact`.
2. For system properties, pass only the needed `property_types`: `email`, `telephone`, `birthday`, `identification`, `address`, or `occupation`.
3. For custom properties, call `list_custom_property_definitions` in the selected account, then pass only returned `property_configuration_id` values as `property_configuration_ids`.
4. Treat both selectors as response projection. They do not filter which contacts match a search, and changing them invalidates an existing search cursor.
5. Expect every matching account-owned value in `properties`, not only the primary one. A selected type or definition with no value returns an empty array.
6. For a `Contact` definition, use only the nested `related_contact.padma_id` and `friendly_name`. CRM omits relationships whose target is not connected to the selected account.

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

## Create or reuse a contact

1. Use `create_contact` only when the user asks to register a person and provides a first name plus an email or phone.
2. Call `search_contacts` first when human review of possible name matches is useful. The write tool itself matches only exact normalized email and phone values in the selected account.
3. Pass `first_name`, at least one of `email` or `phone`, and only the supplied optional `last_name`, two-letter `phone_country`, and `status`.
4. Use only `prospect`, `student`, or `former_student` for `status`; omit it to use `prospect`.
5. If `created` is false, report `matched_by` and `enriched_fields`. Existing names and values are preserved; the tool only fills missing fields.
6. Stop on `identity_conflict`. Do not choose between ambiguous contacts or retry with altered identity data unless the user resolves the conflict.

## Add a contact property

1. Resolve the selected account and contact before writing, and call `add_contact_property` only when the user asks to add the value.
2. Pass `padma_id`, `property_type`, and `value`. Supported types are `email`, `telephone`, `birthday`, `identification`, `address`, `occupation`, and `custom`.
3. Include only metadata accepted by that type: `phone_country`; `identification_type`; address label and location fields; or `custom_label` for a custom string property.
4. Before using a custom label, call `list_custom_property_definitions`. CRM creates a missing String definition, reuses a matching one, and rejects a label configured with another data type.
5. Treat the write as idempotent. Report the returned normalized property and status instead of assuming creation.
6. For birthdays, distinguish `birthday_assigned`, `birthday_unchanged`, and `birthday_preserved_as_custom`; a conflicting incoming date does not replace the canonical birthday.

## Record a communication

1. Resolve the existing contact in the selected account with `search_contacts` or `create_contact`.
2. Call `list_marketing_methods` before sending `marketing_method_ids`, and use only active IDs returned for the selected account.
3. Generate a fresh opaque `request_id` of at most 64 characters for each new communication. Reuse that exact key only when retrying the same payload.
4. Pass the exact approved `observations`, a supported `media`, and only the optional direction, timestamp, coefficient, or marketing methods supplied by the user.
5. Do not supply a username. CRM records the authenticated principal and sanitizes the observations.
6. A replay of the same key and payload returns the original record with `created: false`. Stop on `idempotency_conflict`; use a new key only for a genuinely new communication.
7. Report the persisted communication and contact. Use `get_contact_history` when the user asks to verify its visibility.

## Protect authorization and scope

- Never ask the user to paste an OAuth authorization code or access token into a prompt.
- Never place OAuth credentials in files, URLs, logs, or MCP arguments. The client manages OAuth and DCR.
- Never treat an `account_name` supplied by the user as authorization. Use only an account returned by `list_accounts`.
- Do not switch accounts during a workflow unless the user explicitly asks.
- Do not combine contacts or statistics from different accounts unless the user explicitly requests a clearly separated comparison and each account is authorized.

## Respect write limits

- CRM can create or reuse contacts, add supported system or custom contact properties, record communications, and add contact comments.
- Contact creation only enriches missing identity and relationship fields; it does not overwrite existing contact data.
- Property writes add values and preserve birthday conflicts; they do not expose `public` or `primary` controls.
- CRM cannot otherwise update contacts, statuses, or statistics.
- Do not emulate writes through browser automation or unrelated tools.
- Do not call missing-stat calculation paths or present derived values as persisted CRM statistics.
- If a requested operation is unsupported, explain the boundary and offer the closest available operation.
