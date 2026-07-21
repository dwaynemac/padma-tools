# Money domain model

Use these distinctions before selecting tools or calculating results.

## Business

The PADMA tenant whose financial data is available. OAuth resolves one or more authorized Businesses. `list_businesses` exposes that allowlist, and `business_id` selects one member for a contextual tool call; the ID never grants access by itself.

## Account

A balance-bearing location such as cash, bank, card processor, virtual wallet, or internal current account. Each account has one currency.

An account is not a reporting category. Moving money between two business accounts is a transfer, not income or expense.

## Movement

A financial record with a type, state, source account, amount, movement date, reporting month, and optional related records.

- Income increases the business total.
- Expense decreases the business total.
- Transfer moves value between accounts and must not be counted as income or expense.

Movement state controls balance timing. Reporting month controls report attribution. See `mcp-operations.md` for exact date behavior.

## Category

A hierarchical reporting classification, separate from an account. Child-category values roll up to parent totals. Categories have income or expense sections.

## Contact and agent

Related people used for selection, attribution, filtering, and analysis. The MCP can search contacts but cannot create or update them.

## Plan

A forecast of expected monthly income associated with a contact and category. A plan does not itself create a movement or change category reports.

## Recurrent movement

A rule that creates actual movements over time. Unlike a plan, the generated movements affect reports and potentially balances according to their states.

## Automation rule

A rule applied only when a movement is created. It can assign metadata or convert matching movement types into transfers. Updating a rule does not retroactively change old movements.

## Reporting concepts

- Actual movement date: when the money moved.
- Reconciliation date: when a pending movement began affecting the account balance.
- Reporting month: the administrative month used for reports and plan matching.
- Category subtotal: a deterministic aggregate of report-attributed movements.
- Analysis finding: evidence produced by Money for trends, variance, missing categorization, aging, duplicates, outliers, or date/report-month mismatch.

## Guardrails

- Do not mix realized movements with plan forecasts without labeling them separately.
- Do not add different currencies unless an explicit supported conversion basis is available.
- Do not infer a missing payment until the relevant accounts, date basis, period, pagination, and filters have been checked.
- Do not invent commitments, payables, receivables, budgets, or balances: the current MCP does not expose dedicated tools for them.
