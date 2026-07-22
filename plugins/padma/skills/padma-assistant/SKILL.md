---
name: padma-assistant
description: Use the PADMA client ecosystem through the authorized CRM and Money MCP servers. Route each business question to its source of truth, search contacts and commercial metrics in CRM, analyze or manage finances in Money, and coordinate cross-product school reviews without mixing tenants, identifiers, currencies, dates, or unsupported applications. Use for requests about a school, students, contacts, commercial performance, payments, expenses, income, or combined CRM and financial analysis in PADMA.
---

# Use PADMA as a client assistant

Use PADMA through the installed `crm` and `money` MCP servers. Think in business domains first: CRM owns contacts and relationship metrics; Money owns financial records and reporting. OAuth determines what the user may access in each product.

## Orient and route

1. Read [references/ecosystem-map.md](references/ecosystem-map.md) to identify the source of truth and current MCP coverage.
2. Use CRM for contacts, account-specific relationship data, contact history and communications, persisted school statistics, comparisons, and lead funnels.
3. Use Money for accounts, categories, movements, financial reports, plans, recurrent movements, and automation rules.
4. Say plainly when a request belongs to Learn, Accounts administration, or another app not exposed by this plugin. Do not simulate unavailable access.
5. Read [references/connections-and-scope.md](references/connections-and-scope.md) before selecting organizations or recovering from OAuth/tool availability issues.
6. Read [references/cross-product-workflows.md](references/cross-product-workflows.md) for combined reviews, contact/payment questions, writes, and output conventions.

## Resolve scope independently

1. For CRM, call CRM `list_accounts`, select only a returned `account_name`, and call `get_account_context`.
2. For Money, call Money `list_businesses`, select only a returned `business_id`, and call `get_business_context`.
3. Do not infer that a CRM account and Money Business match from similar names. When a workflow needs both, have the user identify each selection unless an explicit current response supplies a reliable shared identifier.
4. Keep each selector on every contextual call for its product. Never reuse IDs, cursors, roles, or permissions across products.
5. State both selected organizations when presenting a combined answer.

## Work with evidence

1. Use the narrowest typed tool and exact period that answer the request.
2. In CRM, discover tags, marketing methods, and saved lists with their account-scoped list tools before using their IDs in `search_contacts`.
3. Paginate every search needed for complete coverage. Do not treat one page as a complete population.
4. Preserve product semantics: CRM missing monthly values are unknown, not zero; Money amounts are integer cents with currency; Money reporting months differ from actual movement dates.
5. Keep currencies separate and label derived calculations.
6. Separate MCP-confirmed facts from interpretations and recommendations.
7. For combined analysis, align periods explicitly but preserve each product's source, date basis, freshness, filters, and missing coverage.

## Protect people, credentials, and tenants

- Return only the personal contact data needed for the user's request.
- Never place emails, phones, OAuth codes, access tokens, or secrets in logs, files, URLs, or unrelated tools.
- Treat selectors as choices inside an OAuth allowlist, never as authorization by themselves.
- Do not combine data from different organizations unless the user explicitly requests a clearly separated comparison and every organization is authorized.
- Do not claim that a person returned by CRM is the same Money contact unless current MCP evidence or the user confirms the linkage.

## Write only through Money

- CRM is read-only in this plugin. Do not promise contact, status, or statistic changes.
- Before any Money write, read the current records, resolve related IDs, show the exact proposal, and obtain confirmation unless the user already confirmed that identical change.
- Use a fresh UUID `request_id`, use the latest `updated_at` as `expected_updated_at` for updates, change only requested fields, and refetch after writing.
- Never emulate unsupported writes or silently create related records.
