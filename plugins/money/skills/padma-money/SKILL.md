---
name: padma-money
description: Use PADMA Money through its remote MCP server to inspect accounts, categories, contacts, movements, financial reports, recurrent movements, plans, and automation rules, or to create and update supported records safely. Use for requests such as cuanto gastamos, ingresos del mes, flujo de caja, compara periodos, revisa pagos, registra un gasto, corrige o categoriza un movimiento, concilia una cuenta, detecta anomalias, or otherwise consults or manages an organization's financial information stored in Money.
---

# Use Money MCP

Use the `money` MCP server as the only execution path for Money data. OAuth determines the Business allowlist; `business_id` only selects one Business from that authorized set.

## Prepare

1. Confirm that `money` tools are available. Do not substitute browser automation or another integration when the MCP server is unavailable.
2. Call `list_businesses` first. It is the authoritative list of Businesses this OAuth session may use.
3. If the list contains one Business, use it automatically. If it contains several, use a Business explicitly identified by the user or ask which one to use; never guess from unrelated context.
4. Call `get_business_context` for the selected Business. When more than one Business is authorized, pass the selected `id` returned by `list_businesses` as `business_id` and keep that same selector on every contextual tool call in the workflow.
5. State the selected business, currency, and timezone when they matter.
6. Read [references/mcp-operations.md](references/mcp-operations.md) for connection, selection, tool, date, amount, and error contracts.
7. Read [references/domain-model.md](references/domain-model.md) before calculations or when terms could be confused.
8. Read [references/objects-and-attributes.md](references/objects-and-attributes.md) when interpreting a returned object, choosing or changing attributes, or explaining lifecycle and currency effects.
9. Read only the relevant sections of [references/money-product-guide.md](references/money-product-guide.md) when broader product semantics affect the request.
10. Read [references/workflows-and-output.md](references/workflows-and-output.md) for monthly reports, reconciliation, anomaly review, or mutation presentation.

## Read and analyze

1. Use the narrowest typed search tool and filters that answer the question.
2. Paginate when the requested scope exceeds one page. Do not infer a complete result from a truncated page.
3. Preserve Money semantics: `report_on` selects reporting months; `movement_at` and `reconciled_at` select actual dates.
4. Prefer `category_subtotals` for category totals and `analyze_movements` for deterministic findings. Use movement search for detail, audit, categorization, reconciliation, or explaining an aggregate.
5. Calculate from structured integer values, never from formatted display text. Do not add unlike currencies or silently convert them.
6. Present monetary values in human units with their currency while retaining exact integer cents when precision matters.
7. State the business or account scope, period, date basis, currency, filters, and material exclusions.
8. Separate MCP-confirmed facts from interpretation or recommendations. Do not label derived output as an official accounting statement.

## Movement permalinks

When the user requests a direct link to a movement:

1. Use the authenticated `business.id` from `get_business_context` and the `movement.id` from a current `get_movement` or search response.
2. Build `https://<configured-money-host>/businesses/<business.id>/movements/<movement.id>`, preserving the configured MCP server host and removing only its trailing `/mcp` path.
3. Return the result as a clickable Markdown link. Never infer an ID, select a host from the business name, or construct a link for an unverified movement.

## Write safely

1. Read or search the current records before proposing a mutation.
2. Show the exact proposed change, including business, record, amount and currency, dates, and related IDs. Obtain confirmation unless the user already confirmed that exact mutation in the current conversation.
3. Never silently create a missing account, category, contact, or other related record. Search first and ask before creating a missing persistent record.
4. Generate a fresh UUID `request_id` for each intended write. Reuse it only when retrying the identical operation after an uncertain response.
5. For updates, fetch the record immediately before writing and pass its latest `updated_at` as `expected_updated_at`. On conflict, refetch, explain the intervening change, and reconfirm if the proposal changed.
6. Change only explicitly requested fields. Correct an existing record in place instead of creating a duplicate.
7. Refetch or search after the write and report the persisted result. Do not treat a successful request alone as verification.

## Protect credentials and tenant scope

- Never ask the user to paste an OAuth authorization code or access token into a prompt.
- Never place OAuth credentials in files, URLs, logs, or MCP arguments. The client manages the OAuth session.
- Never invent a `business_id` or treat one supplied by the user as authorization. Resolve it through `list_businesses` and use only an ID returned there.
- Treat granted read or write access as permission to operate only within the user's request.
- Do not switch Businesses during a workflow unless the user explicitly asks. If the intended Business is not listed, stop and ask the user to reconnect and grant the required account.

## Handle unavailable or unsupported operations

- If the server or expected tool is unavailable, report the missing capability plainly and provide connection checks from the operations reference.
- Do not emulate deferred capabilities such as deletion, batch mutation, imports, automatic bank-statement matching, or contact mutation through unrelated tools.
- For authentication, authorization, validation, conflict, or rate-limit errors, follow the response-specific recovery in the operations reference. Do not retry writes blindly.
