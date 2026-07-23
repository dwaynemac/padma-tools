# Cross-product workflows

## School overview

1. Resolve the CRM account and Money Business independently.
2. Confirm one common calendar period.
3. In CRM, use persisted monthly statistics, comparisons, or the lead funnel for commercial context.
4. In Money, use category subtotals and deterministic movement analysis for financial context.
5. Present separate CRM and Money evidence before offering a combined interpretation.
6. Label CRM missing months, Money date basis, pagination, currencies, freshness, and material filters.

Do not imply that commercial changes caused financial changes solely because the periods align. Describe correlation as interpretation unless the returned data directly establishes a relationship.

## Contact and payment questions

1. Find the person in CRM within the selected account using the minimum personal data needed.
2. Search Money contacts within the selected Business independently.
3. Link the records only when a stable identifier returned by both current responses or explicit user confirmation supports the match.
4. Search Money plans or movements using the Money contact returned by Money, not a CRM database identifier.
5. Distinguish CRM relationship status from Money payment expectation and realized financial movements.

Absence from one account or Business does not prove that the person does not exist elsewhere. A CRM student status does not prove payment, and a Money plan does not prove learning access.

## Funnel and financial comparison

1. Use CRM `get_lead_funnel` for demand, visits, profile visits, enrollments, and conversions.
2. Use CRM monthly series when zero versus missing funnel source data matters.
3. Use Money reporting-period aggregates for income or expense comparisons; specify `report_on` when the question is about an accounting month.
4. Keep rate deltas as percentage points and financial values in their currencies.
5. Explain changes with evidence from each product; do not manufacture per-contact attribution that the tools did not return.

## Writes in a combined workflow

CRM can add account-visible contact comments and exposes no other writes. Money supports typed creates and updates for movements and selected financial configuration.

### CRM contact comments

Follow the `padma-crm` skill: resolve the account and contact, use the exact user-approved text, call `add_contact_comment` once, and inspect contact history before any retry after an uncertain result.

### Money writes

1. Search and fetch the intended Money records inside the selected Business.
2. Resolve every related Money ID; never reuse a CRM identifier.
3. Check plausible duplicates for new movements.
4. Show Business, operation, account/currency, amount, dates, category, description, and only the fields that will change.
5. Obtain confirmation unless the identical proposal was already confirmed.
6. Use one fresh UUID `request_id`; for updates, pass the latest `updated_at` as `expected_updated_at`.
7. Refetch and report the persisted result. On conflict or uncertain timeout, inspect current state before retrying.

Never create a missing account, category, contact, or other related record implicitly. Never present a CRM read as verification that a Money write persisted.

## Combined answer format

Lead with the outcome, then keep sources auditable:

```markdown
## Panorama

CRM account: <account_name>
Money Business: <business>
Period: <inclusive period>

### Commercial and contacts — CRM
<confirmed metrics, filters, missing months, freshness>

### Financial — Money
<confirmed totals/findings, date basis, currencies, filters>

### Interpretation
<clearly labeled cross-product observations>

### Coverage
<pagination, exclusions, unavailable tools, unresolved identity links>
```
