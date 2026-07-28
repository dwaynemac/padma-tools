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
| `get_contact_list` | optional account, required `list_id`; optional `page_size`, `cursor` | Execute one saved list and return its contacts with properties derived from its configured columns. |
| `list_custom_property_definitions` | optional `account_name` | Discover account-owned custom property IDs, labels, and data types. |
| `search_contacts` | optional account, filters, property selectors, `page_size`, `cursor` | Search account-scoped contact summaries and optionally project selected properties. |
| `get_contact` | optional `account_name`, required `padma_id`; optional property selectors | Read one account-scoped contact detail and optionally project selected properties. |
| `get_contact_learn_activity_summary` | optional `account_name`, required `padma_id` | Read the latest stored Learn activity and churn-risk summary for one account-scoped contact. |
| `get_contact_history` | optional account, required `padma_id`; optional `page_size`, `cursor` | Read the contact activity feed, newest entry first. |
| `add_contact_comment` | optional account, required `padma_id` and `observations` | Add an account-visible follow-up comment as the authenticated user. |
| `create_contact` | optional account; required `first_name` plus `email` or `phone` | Create a contact or reuse an exact account-owned identity, enriching only missing fields. |
| `add_contact_property` | optional account; required `padma_id`, `property_type`, and `value` | Idempotently add a supported account-owned system or custom contact property. |
| `create_communication` | optional account; required `request_id`, `padma_id`, `observations`, and `media` | Record an idempotent account-scoped communication as the authenticated user. |
| `list_monthly_stat_definitions` | optional `account_name` | Discover stable metric names, localized metadata, types, and availability. |
| `get_monthly_stats` | `stat_names`; optional account and month range | Read dense persisted monthly series. |
| `compare_monthly_stats` | `stat_names`; optional account and month | Compare current, previous, and prior-three-month baselines. |
| `get_lead_funnel` | optional account and month range | Aggregate persisted funnel stages and transitions. |

## Saved contact lists

Use `list_contact_lists` for lightweight discovery. Use `get_contact_list` with one returned `list_id` when the user wants that saved list's contacts. CRM executes the saved filters, ordering, and membership semantics; do not attempt to reconstruct the list with `search_contacts`.

The response contains the selected `account_name`, list metadata, contact summaries, and `next_cursor`. List metadata includes the ordered normalized `columns` and a derived `property_selection`. Each contact always has a `properties` array, including an empty array when no configured property has a value.

CRM derives projection from the saved columns:

- `email`, `telephone`, `birthday`, `identification`, and `occupation` select the matching system type;
- `age` selects `birthday`;
- `primary_address` and each `primary_*` address component select `address` once;
- a column exactly matching an account-owned custom-property label selects that definition once.

Computed, operational, duplicate, and stale columns remain visible in `list.columns` but do not add unsupported properties. The saved list is authoritative, so `get_contact_list` does not accept caller property selectors.

## Contact property projection

`list_custom_property_definitions` returns every definition available to the selected account, ordered by label. Each item contains `property_configuration_id`, `label`, and `data_type`: `String`, `Date`, `Integer`, or `Contact`.

Both `get_contact` and `search_contacts` accept these optional selectors:

- `property_types`: unique values from `email`, `telephone`, `birthday`, `identification`, `address`, and `occupation`;
- `property_configuration_ids`: unique positive IDs from the current account's definition list.

When either selector is present, each contact includes a flat `properties` array with every matching account-owned value. The selectors change only response projection, never search matching. Without selectors, the existing compact response is unchanged. Search cursors are bound to the selectors and cannot be reused after changing them.

System values include their applicable phone, identification, address, or birthday metadata. Custom values identify their definition, label, and data type. A `Contact` value returns a nested related contact with only `padma_id` and `friendly_name`; CRM omits a relationship when its target is unavailable in the selected account.

## Contact and communication writes

`create_contact` requires `first_name` and at least one exact identity:

- `email` and `phone` are normalized by CRM and matched only against properties owned by the selected account.
- Optional inputs are `last_name`, two-letter `phone_country`, and `status`: `prospect`, `student`, or `former_student`.
- A unique match is reused without replacing existing values. CRM only fills a missing last name, email, phone, or local status.
- Ambiguous matches or an email and phone belonging to different contacts return `identity_conflict` without writing.
- The response reports `created`, `matched_by`, and `enriched_fields`.

For `add_contact_property`:

- Resolve an existing account-scoped contact and pass `padma_id`, `property_type`, and `value`.
- `property_type` accepts `email`, `telephone`, `birthday`, `identification`, `address`, `occupation`, or `custom`.
- Telephone accepts `phone_country`; identification requires `identification_type`: `dni`, `cpf`, `rg`, or `passport`; address accepts its label and postal/location fields; custom requires `custom_label`.
- Do not send type-specific fields to another type, and do not send `public` or `primary`.
- Custom properties are String-only for this write. CRM creates or reuses an account-scoped String definition and rejects a label already configured with another data type.
- Exact normalized matches return `existing`. Other successful statuses are `created`, `birthday_assigned`, `birthday_unchanged`, and `birthday_preserved_as_custom`.
- A conflicting birthday remains canonical and the incoming value is preserved as the `incoming_birthday` custom property.

For `create_communication`:

- Resolve `padma_id` with `search_contacts` or `create_contact`.
- Pass a fresh opaque `request_id` of 1–64 characters for a new communication.
- `media` must be `social`, `website_contact`, `email`, `messaging`, `phone_call`, or `interview`.
- Optional inputs are ISO 8601 `communicated_at`, `incoming`, `estimated_coefficient`, and active account-owned `marketing_method_ids`.
- `estimated_coefficient` accepts `unknown`, `fp`, `pmenos`, `perfil`, or `pmas`.
- CRM derives the username from OAuth and sanitizes `observations`.
- Replaying the same key and payload returns the original communication with `created: false`. The same key with different data returns `idempotency_conflict`.

For `add_contact_comment`, pass only the resolved `padma_id` and exact approved `observations`. Each call creates a new comment, so inspect `get_contact_history` before retrying an uncertain result.

## Pagination and limits

- Contact pages default to 50 and accept at most 200 records.
- A returned contact cursor is signed and bound to its account, filters, and property projection. Reuse it only for the next page of the identical search.
- A saved-list cursor is signed and bound to its account, list ID, and page size. Reuse it only for the next page of that same list request.
- Contact-history pages use the same 1–200 page-size limit. Reuse their signed cursor only with the same account, `padma_id`, and page size.
- Explicit contact-search dates use strict `YYYY-MM-DD` values.
- Birthday filters use integer `birthday_day`, `birthday_month`, and optional `birthday_year`; omit any component that should not constrain the search.
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
- `identity_conflict`: stop and resolve the ambiguous email or phone identity before retrying.
- `idempotency_conflict`: do not retry the changed payload with the same `request_id`.
- `limit_exceeded`: narrow the page, date range, or metric list.
- `internal_error`: report the correlation ID and avoid blind retries.

HTTP authentication and availability errors have different recovery:

- `401`: reconnect OAuth; verify the exact MCP resource URL.
- `403`: request the `crm` scope or authorize an enabled account.
- `429`: wait for `Retry-After` before retrying.
- `503`: Accounts could not validate the token; retry later without treating it as invalid credentials.
