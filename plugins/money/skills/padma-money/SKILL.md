---
name: padma-money
description: Use PADMA Money through its remote MCP server to inspect accounts, categories, contacts, movements, financial reports, recurrent movements, plans, and automation rules, or to create and update supported records safely. Use for requests such as cuanto gastamos, ingresos del mes, flujo de caja, compara periodos, revisa pagos, registra un gasto, corrige o categoriza un movimiento, concilia una cuenta, detecta anomalias, or otherwise consults or manages an organization's financial information stored in Money.
---

# Use Money MCP

Use the `money` MCP server as the only execution path for Money data. Keep every operation scoped to the business resolved by the configured credential.

## Prepare

1. Confirm that `money` tools are available. Do not substitute browser automation or another integration when the MCP server is unavailable.
2. Call `get_business_context` first. State the connected business, currency, and timezone when they matter.
3. Read [references/mcp-operations.md](references/mcp-operations.md) for connection, tool, date, amount, and error contracts.
4. Read [references/domain-model.md](references/domain-model.md) before calculations or when terms could be confused.
5. Read [references/objects-and-attributes.md](references/objects-and-attributes.md) when interpreting a returned object, choosing or changing attributes, or explaining lifecycle and currency effects.
6. Read only the relevant sections of [references/money-product-guide.md](references/money-product-guide.md) when broader product semantics affect the request.
7. Read [references/workflows-and-output.md](references/workflows-and-output.md) for monthly reports, reconciliation, anomaly review, or mutation presentation.

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

- Never ask the user to paste the API key into a prompt.
- Never place the key in files, URLs, logs, or MCP arguments. The plugin reads `MONEY_MCP_TOKEN` from the environment.
- Never accept or invent a `business_id`; the credential determines the business.
- Treat `full_access` as permission to read and write financial data, not as permission to broaden the user's request.
- Stop on an unexpected business context and ask the user to correct the credential.

## Handle unavailable or unsupported operations

- If the server or expected tool is unavailable, report the missing capability plainly and provide connection checks from the operations reference.
- Do not emulate deferred capabilities such as deletion, batch mutation, imports, automatic bank-statement matching, or contact mutation through unrelated tools.
- For authentication, authorization, validation, conflict, or rate-limit errors, follow the response-specific recovery in the operations reference. Do not retry writes blindly.
