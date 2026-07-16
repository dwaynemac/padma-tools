# Workflows and output

## Contents

- Monthly financial review
- Reconcile an account against supplied evidence
- Review expenses or anomalies
- Record a movement
- Correct or categorize a movement
- Manage recurrent movements, plans, and rules
- Output conventions

## Monthly financial review

1. Resolve the authenticated business with `get_business_context`.
2. Confirm the calendar period, reporting date basis, and currency.
3. Use `category_subtotals` for category totals.
4. Use `analyze_movements` for deterministic findings.
5. Use `search_movements` only for supporting detail, important examples, or unexplained aggregates.
6. Compare with the previous equivalent period only when requested or useful, using identical filters and date basis.
7. Present confirmed totals, changes, findings, exclusions, and incomplete data.

Do not claim an opening or closing account balance because the current tool surface does not expose a dedicated balance-at-date operation.

## Reconcile an account against supplied evidence

The MCP's reconciliation capability is analytical, not automatic bank-statement matching.

1. Identify the account and period.
2. Obtain the external statement or movement list from the user-provided artifact.
3. Search all Money movements for the same account and period, following pagination.
4. Compare structured dates, types, and amounts.
5. Separate exact matches, possible duplicates, missing records, and amount/date differences.
6. Do not modify records until the user chooses the corrections.
7. Apply each confirmed correction with the safe update workflow and verify it.

## Review expenses or anomalies

1. Confirm the reporting period and category/account scope.
2. Use `category_subtotals` for totals and `analyze_movements` for findings.
3. Fetch movement detail only for the findings being explained.
4. Distinguish data facts from interpretation.
5. Describe missing coverage or filters instead of filling gaps with assumptions.

## Record a movement

1. Resolve type, state, source account, target account for transfers, amount, currency, movement date, reporting month, description, and optional relations.
2. Search accounts, categories, contacts, and agents rather than guessing IDs.
3. Search for plausible duplicates using type, account, date, amount, and normalized description.
4. Present the complete proposal.
5. After confirmation, call `create_movement` with one fresh UUID request ID.
6. Refetch the record and report the persisted values.

## Correct or categorize a movement

1. Search and fetch the intended movement.
2. Resolve any new related record through scoped search.
3. Present a before/after summary containing only the requested changes.
4. After confirmation, call `update_movement` with a fresh request ID and the latest `updated_at`.
5. Refetch and verify. Preserve all unrelated fields.

## Manage recurrent movements, plans, and rules

Use the matching `search_*` and `get_*` tool before any create or update. Explain domain effects before confirmation:

- Recurrent movement callbacks may create a movement for the current month when recurrence rules allow it.
- Plan changes affect forecasts and may trigger existing PADMA synchronization behavior.
- Automation rules affect newly created movements, not historical records.

## Output conventions

### Financial summary

```markdown
## Resumen

Negocio: <business>
Período: <inclusive period>
Base: <report_on, movement_at, or reconciled_at>
Alcance: <accounts/categories or whole business>
Moneda: <currency>

Ingresos: <amount, when confirmed>
Egresos: <amount, when confirmed>
Flujo neto: <derived amount, clearly labeled>

## Cambios y hallazgos

<evidence-backed findings>

## Cobertura

<filters, pagination, exclusions, missing data, and assumptions>
```

Omit metrics the MCP data cannot support. Do not insert a fabricated zero.

### Proposed mutation

```markdown
Voy a registrar o modificar:

- Negocio: <business>
- Operación: <create/update and record type>
- Cuenta: <account and currency>
- Monto: <currency and amount>
- Fecha: <movement date>
- Mes de reporte: <month>
- Categoría: <category or none>
- Descripción: <description>
- Otros cambios: <only explicit fields>

Posible duplicado: <none found or candidates>
```

Ask for confirmation after this preview unless the user already confirmed the identical mutation.

### Persisted result

Lead with the outcome, then show the verified final values and record identifier. Mention idempotent replay or unresolved verification when applicable.
