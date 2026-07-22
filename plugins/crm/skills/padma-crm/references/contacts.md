# CRM contacts

## Search

Use `search_contacts` for names, stable `padma_id` values, emails, phones, account relationship state, and recorded activity. Use `status` for one value or `statuses` for several values from the selected account's `contact_statuses`; never send both.

Use the exact input names published by the tool schema:

| Group | Inputs |
|---|---|
| General | `text`, `status`, `statuses` |
| Identity and location | `first_name`, `last_name`, `email`, `telephone`, `identification`, `identification_label`, `gender`, `occupation`, `address`, `neighborhood`, `city`, `state`, `country`, `postal_code`, `younger_than`, `older_than` |
| Current account relationship | `local_teacher`, `coefficient`, `level`, `access_type`, `filiation_tier`, `in_professional_training`, `professional_training_level`, `followed_by_user` |
| Stored relationship dates | `student_on`, `first_enrolled_on_gte`, `first_enrolled_on_lte`, `first_communicated_at_gte`, `first_communicated_at_lte`, `last_communicated_at_gte`, `last_communicated_at_lte`, `last_seen_at_gte`, `last_seen_at_lte`, `last_seen_days_ago_gt`, `last_seen_days_ago_lte`, `last_booking_on_gte`, `last_booking_on_lte` |
| Presence and integrations | `seen`, `never_seen`, `booked`, `never_booked`, `has_gympass`, `has_totalpass`, `has_learn`, `owe_medical_check` |
| Communications | `communication_period`, `communication_period_start`, `communication_period_end`, `communication_direction`, `communication_media`, `contacts_closest_communication_media`, `communication_estimated_coefficient`, `communication_is_trial` |
| Next actions | `next_action_quick_period`, `next_action_period_start`, `next_action_period_end`, `next_action_responsible`, `next_action_booked_by` |
| Visits and remote visits | `televisit_period_start`, `televisit_period_end`, `televisit_usernames`, `visit_period_start`, `visit_period_end`, `visit_usernames`, `has_visits`, `has_no_visits` |
| Trial lessons | `trial_on_lt`, `trial_on_gt`, `with_trial_gt_ago`, `with_trial_lt_ago`, `assisted`, `didnt_trial` |
| Enrollments | `enrolled_days_ago_gt`, `enrolled_days_ago_lt`, `enrollment_period`, `enrollment_period_start`, `enrollment_period_end`, `enrollment_month`, `enrollment_usernames`, `enrollment_access_type` |
| Dropouts | `dropout_period`, `dropout_period_start`, `dropout_period_end`, `drop_out_access_type` |

Explicit dates use `YYYY-MM-DD`. Named period values and other enums must come from the live tool schema. Boolean presence filters apply when sent as `true`; omit them when they should not constrain the search.

## Discover IDs before filtering

- Call `list_tags`, then pass returned `tag_id` values as `tag_ids`.
- Call `list_marketing_methods`, then pass returned active `marketing_method_id` values as `marketing_method_ids`.
- Call `list_contact_lists`, then pass returned `list_id` values as `intersect_list_ids`, `union_list_ids`, or `not_in_list_ids`.

List conjunction semantics are explicit: intersection requires membership in every selected list, union requires membership in any selected list, and exclusion removes members of every selected list. Never copy an ID from another account or reuse discovery results after switching accounts.

Search results are account-scoped summaries. Paginate until the requested scope is complete, or state clearly that the answer covers only the returned page. Do not reuse a cursor after changing the account, any filter, or page size.

## Detail

Use `get_contact` only with a `padma_id` returned by a current CRM call or supplied by the user and confirmed in the selected account. Detail can include name, email, phone, status, teacher, coefficient, last visit, and update timestamp.

Email and phone are resolved from properties belonging to the selected account. Do not infer that another account has the same contact state or operational properties.

## History

Use `get_contact_history` only with a `padma_id` confirmed in the selected account. It returns the newest activity first and can include communications, comments visible to the current user, enrollments, dropouts, sent campaigns, and tracked contact changes.

Each entry includes `id`, `type`, `content`, `username`, `account_name`, `activity_at`, `created_at`, and `updated_at`. Paginate with the returned `next_cursor` when the requested history exceeds one page. Do not reuse that cursor after changing the account, `padma_id`, or page size.

History content can contain sensitive free text. Summarize only the entries relevant to the request, identify their activity dates, and avoid reproducing unrelated notes verbatim.

## Privacy and presentation

- Return the minimum personal data needed to answer the request.
- Do not enumerate contact details when an aggregate or count is sufficient.
- Avoid copying emails or phones into logs, filenames, URLs, or unrelated tools.
- State the selected account when contact identity could be ambiguous.
- Treat `not_found` as absence from the selected authorized account, not proof that the person does not exist elsewhere.
- Keep returned CRM facts separate from guesses about identity, intent, or personal characteristics.

CRM is read-only through this plugin. Do not promise status changes, contact edits, imports, merges, or deletions.
