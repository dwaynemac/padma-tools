---
name: padma-crm
description: Use PADMA CRM through its remote MCP server to find authorized accounts, discover contact metadata and dropout reasons, search or create account-scoped contacts, retrieve saved contact lists with their configured properties and current ages, inspect or create contact properties, read Learn user IDs, activity summaries, and history, create or update communications, record comments, manage authorized Operations projects and recurring tasks, analyze persisted school monthly statistics, compare periods, rank marketing-method conversion and dropout reasons, and review live commercial follow-up or historical lead funnels. Use for requests about CRM contacts, prospects, students, saved lists, ages, custom properties, Learn links, activity or churn risk, dropout-reason segmentation, comments, communications, operational projects or tasks, task recurrence, contact status, enrollment and dropout metrics, acquisition performance, monthly school performance, or commercial funnels stored in PADMA CRM.
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
10. Read [references/monthly-statistics.md](references/monthly-statistics.md) before answering metric, comparison, trend, or either funnel question.

## Search contacts

1. Use `search_contacts` with the narrowest useful identity, relationship, activity, and date filters. For birthdays, use `birthday_day` and `birthday_month`; add `birthday_year` only when the birth year must also match, or omit the day to search a whole birthday month.
2. Before filtering by tags, marketing methods, dropout reasons, or saved lists, call `list_tags`, `list_marketing_methods`, `list_dropout_reasons`, or `list_contact_lists` in the selected account. Use only IDs returned by those current calls.
3. Use `intersect_list_ids` for membership in every selected list, `union_list_ids` for membership in any selected list, and `not_in_list_ids` for exclusions.
4. Paginate when the requested scope exceeds one page. Do not present a truncated page as a complete result or reuse a cursor after changing filters.
5. Use only returned `padma_id` values with `get_contact` or `get_contact_history`; never invent or substitute an identifier.
6. Treat email, phone, Learn user IDs, visits, status, coefficient, teacher, tags, and list membership as personal data. Return only fields needed for the user's request.
7. State the selected account and material filters. Keep facts returned by CRM separate from interpretation.

## Retrieve a saved contact list

1. Call `list_contact_lists` in the selected account and resolve the requested list to a current `list_id`.
2. Call `get_contact_list` when the user wants the contacts produced by that saved list. Do not recreate it with `search_contacts`: CRM applies the list's persisted filters, ordering, and membership semantics.
3. Do not send property selectors. The saved list controls projection through its configured UI columns, and every returned contact includes a `properties` array even when it is empty.
4. Use `list.columns` to report the saved configuration and `list.property_selection` to explain which system property types and custom definitions CRM projected. A saved `age` column returns top-level `age` without exposing a birthday property; other computed, operational, and stale columns can remain in `columns` without producing properties.
5. Paginate with `next_cursor` until the requested scope is complete. Reuse the cursor only with the same account, list ID, and page size.

## Select contact response fields

1. Without response selectors, preserve the compact default projection from `search_contacts` and `get_contact`.
2. Use `response_fields: ["age"]` when the workflow needs the contact's current age rather than the birthdate. The top-level field is `null` when CRM cannot calculate or estimate it.
3. Use `response_fields: ["learn_user_id"]` only when the workflow needs the contact's Learn identifier. The field is `null` when the contact is not linked to Learn.
4. Use `response_fields: ["learn_activity_summary"]` to add the stored Learn snapshot as a top-level field on every returned contact. Combine response field values in one array when several are needed.
5. For system properties, pass only the needed `property_types`: `email`, `telephone`, `birthday`, `identification`, `address`, or `occupation`. Age is a response field, not a property type.
6. For custom properties, call `list_custom_property_definitions` in the selected account, then pass only returned `property_configuration_id` values as `property_configuration_ids`.
7. Treat all three selectors as response projection. They do not filter which contacts match a search, and changing them invalidates an existing search cursor.
8. Expect every matching account-owned property value in `properties`, not only the primary one. A selected type or definition with no value returns an empty array.
9. For a `Contact` definition, use only the nested `related_contact.padma_id` and `friendly_name`. CRM omits relationships whose target is not connected to the selected account.

## Inspect Learn activity

1. Resolve the contact in the selected account with a current `padma_id`.
2. Call `get_contact` with `account_name`, `padma_id`, and `response_fields: ["learn_activity_summary"]`. Use the same `response_fields` selector with `search_contacts` when summaries are needed for several matching contacts.
3. Interpret the returned values using [references/learn-activity-summary.md](references/learn-activity-summary.md). In particular, treat deltas as ratios rather than percentage-point changes.
4. Report only the returned activity, attendance, cancellation, and churn-risk signals. The summary is `null` when Learn has not calculated it.
5. Treat the values as a snapshot calculated by Learn, not a prediction or diagnosis made by the agent.

## Analyze statistics and funnels

1. Discover stable metric names with `list_monthly_stat_definitions`; do not invent a `stat_name` from a translated label.
2. Use `get_monthly_stats` for exact series and freshness and `compare_monthly_stats` for shared dashboard comparison semantics.
3. Use `get_marketing_method_statistics` for distinct communication, qualified communication, qualified interview, and enrollment contact counts by marketing method, with CRM-calculated conversion percentages.
4. Use `get_dropout_reason_statistics` for distinct dropout contact counts by account-defined reason. Call `list_dropout_reasons` first when the user names a reason or needs its current ID.
5. Both ranking tools accept optional strict `start_month` and `end_month` values, default to the 12 months ending with the current account-local month, and accept at most 36 months.
6. Use `get_commercial_funnel` when the question is operational: which prospects need attention now, how many contacts are in each current follow-up stage, or which stage list to work. Use a returned `list_id` with `get_contact_list` and paginate that list when contacts are requested.
7. Use `get_lead_funnel` when the question is analytical: how demand converted through visits and profile visits into enrollments over a monthly range.
8. Never treat commercial-funnel stage counts as a historical conversion series or calculate conversion rates from them. They are live saved contact searches, not one period cohort.
9. The first `get_commercial_funnel` call may initialize missing internal system searches, as the CRM dashboard does; it does not modify contacts.
10. Preserve missing absolute values as unknown. Never convert `value: null` into zero or calculate a missing absolute statistic outside CRM.
11. Do not request deprecated rate `stat_name` values. Derive a requested percentage from the documented absolute numerator and denominator only when both are present and the denominator is greater than zero.
12. State the selected account and resolved monthly range for ranking and historical-funnel results. For a commercial funnel, state that the counts are a current snapshot. Include missing months and freshness when they affect an analytical answer.

## Create a contact comment

1. Use `create_contact_comment` only when the user explicitly asks to record a comment and supplies or approves the exact text.
2. Resolve the selected account and contact first. Use a current `padma_id` from `search_contacts`, and disambiguate same-name contacts before writing.
3. State the selected account and contact before the write when identity could be ambiguous. Never send a comment to a merely similar contact.
4. Call `create_contact_comment` once with `account_name`, `padma_id`, and `observations`. The server records the authenticated username and current time; the comment is visible to the selected account.
5. Treat the tool as non-idempotent. If the result is uncertain, inspect `get_contact_history` before retrying so the same comment is not created twice.
6. Report the created comment and contact. Do not claim success from intent or an OAuth login alone.

## Create or reuse a contact

1. Use `create_contact` only when the user asks to register a person and provides a first name plus an email or phone.
2. Call `search_contacts` first when human review of possible name matches is useful. The write tool itself matches only exact normalized email and phone values in the selected account.
3. Pass `first_name`, at least one of `email` or `phone`, and only the supplied optional `last_name`, two-letter `phone_country`, and `status`.
4. Use only `prospect`, `student`, or `former_student` for `status`; omit it to use `prospect`.
5. If `created` is false, report `matched_by` and `enriched_fields`. Existing names and values are preserved; the tool only fills missing fields.
6. Stop on `identity_conflict`. Do not choose between ambiguous contacts or retry with altered identity data unless the user resolves the conflict.

## Create a contact property

1. Resolve the selected account and contact before writing, and call `create_contact_property` only when the user asks to add the value.
2. Pass `padma_id`, `property_type`, and `value`. Supported types are `email`, `telephone`, `birthday`, `identification`, `address`, `occupation`, and `custom`.
3. Include only metadata accepted by that type: `phone_country`; `identification_type`; address label and location fields; or `custom_label` for a custom string property.
4. Before using a custom label, call `list_custom_property_definitions`. CRM creates a missing String definition, reuses a matching one, and rejects a label configured with another data type.
5. Treat the write as idempotent. Report the returned normalized property and status instead of assuming creation.
6. For birthdays, distinguish `birthday_assigned`, `birthday_unchanged`, and `birthday_preserved_as_custom`; a conflicting incoming date does not replace the canonical birthday.

## Record a communication

1. Resolve the existing contact in the selected account with `search_contacts` or `create_contact`.
2. Call `list_marketing_methods` before sending `marketing_method_ids`, and use only active IDs returned for the selected account.
3. Generate a fresh opaque `request_id` of at most 64 characters for each new communication. Reuse that exact key only when retrying the same payload.
4. Call `create_contact_communication` with the exact approved `observations`, a supported `media`, and only the optional direction, timestamp, coefficient, or marketing methods supplied by the user.
5. Do not supply a username. CRM records the authenticated principal and sanitizes the observations.
6. A replay of the same key and payload returns the original record with `created: false`. Stop on `idempotency_conflict`; use a new key only for a genuinely new communication.
7. Report the persisted communication and contact. Use `get_contact_history` when the user asks to verify its visibility.

## Update a contact communication

1. Use `update_contact_communication` only when the user explicitly asks to correct an existing communication.
2. Resolve the selected account and exact communication first. Use the `object_id` from its `Communication` entry in `get_contact_history`, or the `id` returned by `create_contact_communication`.
3. Pass `communication_id` and only the approved editable fields: `observations`, `media`, `communicated_at`, `incoming`, `estimated_coefficient`, or `marketing_method_ids`. Omitted fields are preserved.
4. Treat `marketing_method_ids` as a complete replacement. Call `list_marketing_methods` first, use only active IDs from the selected account, and send an empty array only when the user explicitly wants to clear every method.
5. Do not attempt to change the account, contact, author, request ID, or idempotency metadata; the tool does not accept them.
6. Repeating the same update is idempotent and returns `updated: false`. Report whether CRM changed the record.

## Manage Operations projects and tasks

1. Call `list_operations_projects` when a request names a project, needs project discovery, or will assign or filter tasks by project. Use only a `project_id` returned for the selected account.
2. Use `list_operations_tasks` for task requests. It defaults to every active task the authenticated user can read, including later work; use `status`, `due_group`, `assignee_username`, `contact_padma_id`, or `project_id` only when the request needs that filter. Omit `project_id` to include every project; send explicit `null` to return only tasks without a project.
3. Follow `next_cursor` until the requested scope is complete. Never reuse a task cursor after changing the account, filters, or page size.
4. Call `list_operations_assignees` before creating a task or changing its assignee, and use only a username returned for the selected account.
5. Resolve a linked contact through `search_contacts` and pass its public `padma_id`; never pass CRM's internal contact ID.
6. Create a task only when the user explicitly requests it. State the selected account, title, assignee, due date, linked contact, project, description, and recurrence before writing when any value is ambiguous. Creation is not idempotent, so inspect the task list before retrying an uncertain result.
7. Pass recurrence as `null` or `{ frequency, interval, ends_on }`. Frequency is `daily`, `weekly`, `monthly`, or `yearly`; interval is a positive integer and defaults to `1`; `ends_on` is an optional strict `YYYY-MM-DD`. A recurring task requires `due_on`.
8. For updates, resolve the exact `task_id` from `list_operations_tasks` and pass only approved editable fields. Omitted fields stay unchanged; `null` clears the description, due date, linked contact, project, or recurrence. Once a task has generated its successor, change recurrence on that successor instead.
9. Use `complete_operations_task` and `reopen_operations_task` only for the exact resolved task. Both are idempotent. Completing a recurring task atomically creates at most one successor on the first future occurrence and returns `next_task_id`; reopening preserves that successor and completing again does not duplicate it. Report whether the response changed state and identify the successor when present.
10. Treat `delete_operations_task` as permanent and destructive. Show the resolved task and obtain explicit confirmation immediately before deleting it.
11. Create, rename, or delete a project only for an authenticated admin or director with CRM write capability. Project names are account-scoped; resolve the exact project before updating it.
12. Treat `delete_operations_project` as destructive even though it preserves tasks. Show the resolved project, obtain explicit confirmation immediately before deletion, and report `unassigned_tasks_count` because those tasks become unassigned from any project.
13. Respect `forbidden` as an authorization boundary. Do not attempt to bypass assignment, creator, role, account, write-capability, or feature-level restrictions.

## Protect authorization and scope

- Never ask the user to paste an OAuth authorization code or access token into a prompt.
- Never place OAuth credentials in files, URLs, logs, or MCP arguments. The client manages OAuth and DCR.
- Never treat an `account_name` supplied by the user as authorization. Use only an account returned by `list_accounts`.
- Do not switch accounts during a workflow unless the user explicitly asks.
- Do not combine contacts or statistics from different accounts unless the user explicitly requests a clearly separated comparison and each account is authorized.

## Respect write limits

- CRM can create or reuse contacts, create supported system or custom contact properties, create or update communications, create contact comments, and manage Operations projects and tasks within the authenticated user's permissions.
- Contact creation only enriches missing identity and relationship fields; it does not overwrite existing contact data.
- Property writes add values and preserve birthday conflicts; they do not expose `public` or `primary` controls.
- CRM cannot otherwise update contacts, statuses, or statistics.
- Do not emulate writes through browser automation or unrelated tools.
- Do not call missing-stat calculation paths or present derived values as persisted CRM statistics.
- If a requested operation is unsupported, explain the boundary and offer the closest available operation.
