# Cross-product workflows

## School overview

1. Resolve the CRM account and Money Business independently.
2. Confirm one common calendar period.
3. In CRM, use persisted monthly statistics, comparisons, or `get_lead_funnel` for historical commercial context. Use `get_commercial_funnel` only when the overview also needs the contacts requiring follow-up now.
4. In Money, use category subtotals and deterministic movement analysis for financial context.
5. Present separate CRM and Money evidence before offering a combined interpretation.
6. Label CRM missing months, Money date basis, pagination, currencies, freshness, and material filters.

Do not imply that commercial changes caused financial changes solely because the periods align. Describe correlation as interpretation unless the returned data directly establishes a relationship.

## Contact and payment questions

1. Resolve the CRM account and Money Business independently through `list_accounts` and `list_businesses`. Keep `account_name` only on CRM calls and `business_id` only on Money calls.
2. Find the person in CRM within the selected account using the minimum personal data needed. Confirm the intended result and retain its current `padma_id`.
3. For Money contact metadata or membership verification, call `search_contacts(padma_id: crm_contact.padma_id)` inside the selected Money Business. This is an exact match and returns an empty collection when that contact is not connected to the Business.
4. For realized movements, call `search_movements(contact_padma_id: crm_contact.padma_id, ...)` directly with an explicit date field and period. Do not perform an intermediate lookup merely to obtain Money's integer `contact_id`.
5. Do not send `contact_id` together with `contact_padma_id`. An unknown or out-of-Business `contact_padma_id` returns `not_found`.
6. Paginate Money movement results when `next_cursor` is present and preserve the same contact, period, page size, and Business filters on every page.
7. Distinguish CRM relationship status from Money payment expectation and realized financial movements.

The cross-product call shape is:

```text
CRM search_contacts(account_name: selected_crm_account, ...)
  -> crm_contact.padma_id
Money search_contacts(business_id: selected_money_business, padma_id: crm_contact.padma_id)
Money search_movements(business_id: selected_money_business, contact_padma_id: crm_contact.padma_id, date_field: ..., from: ..., to: ...)
```

`padma_id` is the shared identity key. It does not authorize either product, select an organization, or prove that similarly named CRM and Money tenants correspond.

Absence from one account or Business does not prove that the person does not exist elsewhere. A CRM student status does not prove payment, and a Money plan does not prove learning access.

## Funnel and financial comparison

1. Use CRM `get_lead_funnel` for demand, visits, profile visits, enrollments, and conversions.
2. Use CRM monthly series when zero versus missing funnel source data matters.
3. Use Money reporting-period aggregates for income or expense comparisons; specify `report_on` when the question is about an accounting month.
4. Keep rate deltas as percentage points and financial values in their currencies.
5. Explain changes with evidence from each product; do not manufacture per-contact attribution that the tools did not return.

`get_commercial_funnel` answers a different question: it is a current
operational snapshot of acquisition, qualified, booked, trialed, and enrolled
contact lists. Use it when the user wants present follow-up workload, then open
a returned `list_id` with `get_contact_list`. Do not compare those live list
counts with historical Money periods as if they were conversion metrics.

## Writes in a combined workflow

CRM can create or reuse contacts, add supported properties, record communications, and add account-visible contact comments. Money supports typed creates and updates for movements and selected financial configuration, plus recoverable movement deletion.

### CRM contact and communication writes

Follow the `padma-crm` skill and keep the selected `account_name`:

- For a new person, call `create_contact` with a first name and exact email or phone. Stop on ambiguous identity instead of choosing a candidate.
- For a contact property, resolve the contact, discover custom definitions when relevant, and call `add_contact_property` with only type-specific fields. Treat normalized duplicates as successful reuse.
- For a communication, resolve the contact, discover any marketing methods, and use one fresh `request_id`. Reuse it only for an identical retry.
- For a comment, use the exact user-approved text, call `add_contact_comment` once, and inspect contact history before retrying an uncertain result.

Do not treat CRM contact creation as permission to create a related Money contact or record.

### Money writes

1. Search and fetch the intended Money records inside the selected Business.
2. Resolve every related Money ID; never reuse a CRM identifier.
3. Check plausible duplicates for new movements.
4. Show Business, operation, account/currency, amount, dates, category, description, and, for updates, only the fields that will change.
5. Obtain confirmation unless the identical proposal was already confirmed.
6. Use one fresh UUID `request_id`; for updates and movement deletion, pass the latest `updated_at` as `expected_updated_at`.
7. Verify and report the result. Refetch creates and updates; for a deleted movement, verify that normal Money reads return `not_found`. On conflict or uncertain timeout, inspect current state before retrying.

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
