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
| `list_dropout_reasons` | optional `account_name` | Discover account dropout reason IDs and values for `dropout_reason_ids`. |
| `list_contact_lists` | optional `account_name` | Discover saved contact-list IDs and names. |
| `get_contact_list` | optional account, required `list_id`; optional `page_size`, `cursor` | Execute one saved list and return its contacts with fields derived from its configured columns, including top-level age. |
| `list_custom_property_definitions` | optional `account_name` | Discover account-owned custom property IDs, labels, and data types. |
| `search_contacts` | optional account, filters, response selectors, `page_size`, `cursor` | Search account-scoped contact summaries and optionally project age, selected properties, Learn user IDs, or activity summaries. |
| `get_contact` | optional `account_name`, required `padma_id`; optional response selectors | Read one account-scoped contact detail and optionally project age, selected properties, its Learn user ID, or activity summary. |
| `get_contact_history` | optional account, required `padma_id`; optional `page_size`, `cursor` | Read the contact activity feed, newest entry first. |
| `create_contact` | optional account; required `first_name` plus `email` or `phone` | Create a contact or reuse an exact account-owned identity, enriching only missing fields. |
| `create_contact_comment` | optional account, required `padma_id` and `observations` | Create an account-visible follow-up comment as the authenticated user. |
| `create_contact_property` | optional account; required `padma_id`, `property_type`, and `value` | Idempotently create a supported account-owned system or custom contact property. |
| `create_contact_communication` | optional account; required `request_id`, `padma_id`, `observations`, and `media` | Create an idempotent account-scoped communication as the authenticated user. |
| `update_contact_communication` | optional account; required `communication_id` and at least one editable field | Update approved fields on an account-scoped communication. |
| `list_operations_assignees` | optional `account_name` | Discover usernames available for Operations task assignment. |
| `list_operations_projects` | optional `account_name` | List account-scoped Operations projects and their sorted members in alphabetical order. |
| `create_operations_project` | optional account; required `name`; optional `member_usernames` | Create an Operations project and optional complete member list when authorized. |
| `update_operations_project` | optional account; required `project_id` and at least one of `name` or `member_usernames` | Partially update a project; membership is a complete replacement and `[]` clears it. |
| `delete_operations_project` | optional account; required `project_id` | Delete a project, preserve its tasks, and report how many became unassigned. |
| `list_operations_tasks` | optional account, task filters, `page_size`, `cursor` | List signed-cursor pages of Operations tasks readable by the authenticated user. |
| `create_operations_task` | optional account; required `title`; optional collaborators and recurrence | Create an Operations task with server-owned creator attribution and optional complete collaborator list. |
| `update_operations_task` | optional account; required `task_id` and at least one editable field | Partially update an authorized task, including replacing collaborators or setting or clearing recurrence. |
| `complete_operations_task` | optional account; required `task_id` | Idempotently complete a task and return any recurring successor. |
| `reopen_operations_task` | optional account; required `task_id` | Idempotently reopen a completed task. |
| `delete_operations_task` | optional account; required `task_id` | Permanently delete a task when authorized. |
| `list_monthly_stat_definitions` | optional `account_name` | Discover stable metric names, localized metadata, types, and availability. |
| `get_monthly_stats` | `stat_names`; optional account and month range | Read dense persisted monthly series. |
| `compare_monthly_stats` | `stat_names`; optional account and month | Compare current, previous, and prior-three-month baselines. |
| `get_lead_funnel` | optional account and month range | Analyze the historical four-stage conversion funnel from persisted monthly statistics. |
| `get_commercial_funnel` | optional `account_name` | Read the five live operational follow-up stages with localized labels, descriptions, contact counts, and actionable saved-list IDs. |
| `get_marketing_method_statistics` | optional account, `start_month`, `end_month` | Count distinct communication and enrollment contacts by marketing method and return conversion percentages. |
| `get_dropout_reason_statistics` | optional account, `start_month`, `end_month` | Count distinct dropout contacts by account-defined reason. |

## Ranking statistics

Use `get_marketing_method_statistics` to compare account-defined acquisition
methods over a resolved monthly range. Each row identifies the current
marketing method, whether it is archived, distinct contact counts for
communications, qualified communications, qualified interviews, and
enrollments, plus CRM-calculated communication-to-enrollment and
interview-to-enrollment percentages. A percentage can be `null` when its
denominator is zero.

Use `get_dropout_reason_statistics` to compare distinct dropout contacts by
reason. Call `list_dropout_reasons` first when the user names a reason or needs
the current account-owned ID. Reasons are account-defined; do not infer a
standard meaning from their label.

Both tools accept optional strict `start_month` and `end_month` values in
`YYYY-MM`. They default to the 12 months ending with the current account-local
month, reject reversed ranges, and accept at most 36 months. Their results are
calculated from CRM communication, enrollment, and dropout records for the
selected range; they are not persisted monthly-stat series. Keep accounts
separate and report the resolved range from the response.

## Choose the correct funnel

Use `get_commercial_funnel` for current operational work. It answers “Which
contacts need follow-up now?” and returns acquisition, qualified, booked,
trialed, and enrolled stages. Each stage includes a `list_id`; pass that ID to
`get_contact_list` and follow its cursor when the user asks for the contacts.
The stage counts are live saved-search populations, not a historical cohort, so
do not derive conversion percentages from them. Like the web dashboard, the
first call may initialize missing internal system searches without modifying
contacts.

Use `get_lead_funnel` for historical analysis. It answers “How did demand
convert into enrollments over this monthly range?” and returns demand, visits,
profile visits, and enrollments with percent-of-initial and transition
conversion values. Query the corresponding monthly series when the difference
between a persisted zero and missing source data matters.

## Saved contact lists

Use `list_contact_lists` for lightweight discovery. Use `get_contact_list` with one returned `list_id` when the user wants that saved list's contacts. CRM executes the saved filters, ordering, and membership semantics; do not attempt to reconstruct the list with `search_contacts`.

The response contains the selected `account_name`, list metadata, contact summaries, and `next_cursor`. List metadata includes the ordered normalized `columns` and a derived `property_selection`. Each contact always has a `properties` array, including an empty array when no configured property has a value.

CRM derives projection from the saved columns:

- `email`, `telephone`, `birthday`, `identification`, and `occupation` select the matching system type;
- `age` adds top-level computed age without selecting or exposing `birthday`;
- `primary_address` and each `primary_*` address component select `address` once;
- a column exactly matching an account-owned custom-property label selects that definition once.

Computed, operational, duplicate, and stale columns remain visible in `list.columns` but do not add unsupported properties. The saved list is authoritative, so `get_contact_list` does not accept caller property selectors.

## Contact response projection

`list_custom_property_definitions` returns every definition available to the selected account, ordered by label. Each item contains `property_configuration_id`, `label`, and `data_type`: `String`, `Date`, `Integer`, or `Contact`.

Both `get_contact` and `search_contacts` accept these optional selectors:

- `response_fields`: unique values from the additional top-level fields currently supported: `age`, `learn_user_id`, and `learn_activity_summary`;
- `property_types`: unique values from `email`, `telephone`, `birthday`, `identification`, `address`, and `occupation`;
- `property_configuration_ids`: unique positive IDs from the current account's definition list.

When either property selector is present, each contact includes a flat `properties` array with every matching account-owned value. Selecting `age` adds CRM's current computed or estimated age as a top-level field; it is `null` when unavailable and does not expose the birthdate. Selecting `learn_user_id` adds the contact's Learn identifier as a top-level field; it is `null` when the contact is not linked to Learn. Selecting `learn_activity_summary` adds the latest normalized Learn snapshot; it is `null` when Learn has not calculated one. The selectors can be combined and change only response projection, never search matching. Without selectors, the existing compact response is unchanged. Search cursors are bound to all selectors and cannot be reused after changing them.

System values include their applicable phone, identification, address, or birthday metadata. Custom values identify their definition, label, and data type. A `Contact` value returns a nested related contact with only `padma_id` and `friendly_name`; CRM omits a relationship when its target is unavailable in the selected account.

## Contact and communication writes

`create_contact` requires `first_name` and at least one exact identity:

- `email` and `phone` are normalized by CRM and matched only against properties owned by the selected account.
- Optional inputs are `last_name`, two-letter `phone_country`, and `status`: `prospect`, `student`, or `former_student`.
- A unique match is reused without replacing existing values. CRM only fills a missing last name, email, phone, or local status.
- Ambiguous matches or an email and phone belonging to different contacts return `identity_conflict` without writing.
- The response reports `created`, `matched_by`, and `enriched_fields`.

For `create_contact_property`:

- Resolve an existing account-scoped contact and pass `padma_id`, `property_type`, and `value`.
- `property_type` accepts `email`, `telephone`, `birthday`, `identification`, `address`, `occupation`, or `custom`.
- Telephone accepts `phone_country`; identification requires `identification_type`: `dni`, `cpf`, `rg`, or `passport`; address accepts its label and postal/location fields; custom requires `custom_label`.
- Do not send type-specific fields to another type, and do not send `public` or `primary`.
- Custom properties are String-only for this write. CRM creates or reuses an account-scoped String definition and rejects a label already configured with another data type.
- Exact normalized matches return `existing`. Other successful statuses are `created`, `birthday_assigned`, `birthday_unchanged`, and `birthday_preserved_as_custom`.
- A conflicting birthday remains canonical and the incoming value is preserved as the `incoming_birthday` custom property.

For `create_contact_communication`:

- Resolve `padma_id` with `search_contacts` or `create_contact`.
- Pass a fresh opaque `request_id` of 1–64 characters for a new communication.
- `media` must be `social`, `website_contact`, `email`, `messaging`, `phone_call`, or `interview`.
- Optional inputs are ISO 8601 `communicated_at`, `incoming`, `estimated_coefficient`, and active account-owned `marketing_method_ids`.
- `estimated_coefficient` accepts `unknown`, `fp`, `pmenos`, `perfil`, or `pmas`.
- CRM derives the username from OAuth and sanitizes `observations`.
- Replaying the same key and payload returns the original communication with `created: false`. The same key with different data returns `idempotency_conflict`.

For `update_contact_communication`:

- Resolve the exact communication in the selected account. Use the `object_id` from its `Communication` history entry or the `id` returned by `create_contact_communication`.
- Pass `communication_id` and at least one of `observations`, `media`, ISO 8601 `communicated_at`, `incoming`, `estimated_coefficient`, or `marketing_method_ids`.
- Omitted fields are preserved. `marketing_method_ids` is a complete replacement; an empty array clears every method.
- Account, contact, username, request ID, and idempotency fingerprint cannot be changed.
- Repeating an identical update returns `updated: false`.

For `create_contact_comment`, pass only the resolved `padma_id` and exact approved `observations`. Each call creates a new comment, so inspect `get_contact_history` before retrying an uncertain result.

## Operations projects and tasks

Operations tools use the same account, feature-level, assignment, creator,
collaborator, project-membership, and role authorization as CRM's task interface. A regular authorized member can
read and update tasks assigned to them or created by them, and can delete tasks
they created. A project member can read every task in that project without gaining
task mutation rights. Account admins and directors can manage team tasks. A principal
without write capability can list readable tasks but cannot mutate them. Every
user who can access Operations tasks can list the selected account's projects;
only account admins and directors with write capability can create, rename, or
delete projects.

`list_operations_projects` returns the current account's projects alphabetically
as stable `project_id`, `name`, and sorted `member_usernames` values. Project IDs
and member usernames are account-scoped: discover
them in the selected account and never reuse one from another account.

Call `list_operations_tasks` without filters to get every active readable task,
including later work. Optional filters are:

- `status`: `active`, `completed`, or `all`;
- `due_group`: `overdue`, `today`, `upcoming`, `later`, or `unscheduled`;
- `assignee_username`, discovered with `list_operations_assignees`;
- `contact_padma_id`, resolved through CRM contact tools;
- `project_id`: omit it to include every project, pass `null` for only tasks
  without a project, or pass an ID from `list_operations_projects`.

Do not combine a due group with `status: completed`. Responses include
`task_id`, editable fields, creator and completion attribution, `due_group`,
audit timestamps, a linked contact's public `padma_id` and friendly name,
sorted `collaborator_usernames`,
`project` as `{ project_id, name, member_usernames }` or `null`, `recurrence` as
`{ frequency, interval, ends_on }` or `null`, `generated_from_task_id`, and
`next_task_id`. The task ID is account-scoped and must come from a current list
response.

For task writes:

- `create_operations_task` requires `title` and accepts `description`,
  `assignee_username`, complete-replacement `collaborator_usernames`, strict
  `YYYY-MM-DD` `due_on`, `contact_padma_id`, nullable `project_id`, and
  `recurrence`. Every collaborator must belong to the selected account; creator
  and assignee are implicit participants and are omitted from the stored list.
  The server supplies the account and creator, and defaults the assignee to the
  authenticated user. Creation is not idempotent.
- `recurrence` is `null` or `{ frequency, interval, ends_on }`. Frequency is
  `daily`, `weekly`, `monthly`, or `yearly`; interval is a positive integer and
  defaults to `1`; `ends_on` is an optional strict `YYYY-MM-DD` inclusive limit.
  Setting recurrence requires `due_on`.
- `update_operations_task` accepts only `title`, `description`,
  `assignee_username`, `collaborator_usernames`, `due_on`, `contact_padma_id`,
  `project_id`, and `recurrence`. Omitted fields are preserved;
  `collaborator_usernames` is a complete replacement and `[]` clears it;
  `null` clears description, due date, contact, project, or recurrence.
  Recurrence cannot change after a task has generated a successor; update the
  active successor instead. Creator, completion attribution, account, and task
  ID cannot be changed.
- Completion and reopening are idempotent and report whether they changed the
  task. Completing a recurring task atomically creates at most one successor on
  the first future occurrence, skips missed dates, respects the inclusive end
  date, and returns `next_task_id`. Reopening preserves an existing successor,
  and completing the same task again does not duplicate it. Deletion is
  permanent, destructive, and not idempotent.
- Resolve and show the exact task before a destructive deletion. If a create
  result is uncertain, list matching tasks before retrying.

Project writes use an exact account-scoped `project_id`. Names are trimmed, at
most 255 characters, and unique within the account without regard to case.
`create_operations_project` requires a name and accepts optional
`member_usernames`. `update_operations_project` requires at least one of `name`
or complete-replacement `member_usernames`; omitted fields remain unchanged and
an empty member list clears membership. Every member must be a current user of
the selected account. Both tools return the project metadata.
`delete_operations_project` returns the deleted project and
`unassigned_tasks_count`; it never deletes the project's tasks, but leaves them
without a project. Confirm this destructive project deletion immediately before
calling it.

## Pagination and limits

- Contact pages default to 50 and accept at most 200 records.
- A returned contact cursor is signed and bound to its account, filters, and response projection. Reuse it only for the next page of the identical search.
- A saved-list cursor is signed and bound to its account, list ID, and page size. Reuse it only for the next page of that same list request.
- Contact-history pages use the same 1–200 page-size limit. Reuse their signed cursor only with the same account, `padma_id`, and page size.
- Operations task pages use the same 1–200 page-size limit. Reuse their signed cursor only with the same account, filters, and page size.
- Explicit contact-search dates use strict `YYYY-MM-DD` values.
- Birthday filters use integer `birthday_day`, `birthday_month`, and optional `birthday_year`; omit any component that should not constrain the search.
- `status` accepts one value; `statuses` accepts several. Do not send both.
- Call the matching discovery tool before using `tag_ids`, `marketing_method_ids`, `dropout_reason_ids`, `intersect_list_ids`, `union_list_ids`, or `not_in_list_ids`. IDs from another account are rejected.
- Monthly series and ranking-statistics ranges default to 12 months ending with the current account-local month and accept at most 36 months.
- Statistics tools accept 1–20 supported `stat_names` per call.
- Month strings are strict `YYYY-MM` values.

## Error handling

Tool-level domain errors return `isError: true` with a stable code:

- `account_required`: select an account returned by `list_accounts`.
- `forbidden`: do not retry with invented account names; refresh authorization and account discovery.
- `not_found`: confirm the current account and identifier.
- `validation_failed`: correct names, dates, statuses, cursor, or other input.
- `identity_conflict`: stop and resolve the ambiguous email or phone identity before retrying.
- `idempotency_conflict`: do not retry the changed payload with the same `request_id`.
- `limit_exceeded`: narrow the page, date range, or metric list.
- `internal_error`: report the correlation ID and avoid blind retries.

HTTP authentication and availability errors have different recovery:

- `401`: reconnect OAuth; verify the exact MCP resource URL.
- `403`: request the `crm` scope or authorize an enabled account.
- `429`: wait for `Retry-After` before retrying.
- `503`: Accounts could not validate the token; retry later without treating it as invalid credentials.
