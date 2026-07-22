# CRM contacts

## Search

Use `search_contacts` for names, stable `padma_id` values, emails, or phones. Add `status` only from the selected account's `contact_statuses` returned by `get_account_context`.

Search results are account-scoped summaries. Paginate until the requested scope is complete, or state clearly that the answer covers only the returned page. Do not reuse a cursor after changing account, text, status, or page size.

## Detail

Use `get_contact` only with a `padma_id` returned by a current CRM call or supplied by the user and confirmed in the selected account. Detail can include name, email, phone, status, teacher, coefficient, last visit, and update timestamp.

Email and phone are resolved from properties belonging to the selected account. Do not infer that another account has the same contact state or operational properties.

## Privacy and presentation

- Return the minimum personal data needed to answer the request.
- Do not enumerate contact details when an aggregate or count is sufficient.
- Avoid copying emails or phones into logs, filenames, URLs, or unrelated tools.
- State the selected account when contact identity could be ambiguous.
- Treat `not_found` as absence from the selected authorized account, not proof that the person does not exist elsewhere.
- Keep returned CRM facts separate from guesses about identity, intent, or personal characteristics.

CRM is read-only through this plugin. Do not promise status changes, contact edits, imports, merges, or deletions.
