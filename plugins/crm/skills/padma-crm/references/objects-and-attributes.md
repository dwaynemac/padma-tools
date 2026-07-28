# CRM objects and attributes

Interpret CRM records with these product semantics. The names shown are the MCP names when a direct equivalent exists; consult `mcp-operations.md` for the available tool schemas.

## Contact

- A contact is a person related to the school, such as a prospect, student, former student, teacher, or another relationship represented by that school's configured statuses.
- Contact details, status, activity, assigned teacher, tags, marketing methods, and list membership are scoped to the selected account. Do not infer that another school has the same information for the person.

## Contact properties

- System properties represent email, telephone, birthday, identification, address, and occupation values owned by the selected account.
- Custom property definitions are account-scoped labels with `String`, `Date`, `Integer`, or `Contact` data types. Their numeric IDs are selectors, not portable identifiers across accounts.
- Property selectors on contact reads control projection only; they do not filter the contacts returned by a search.
- A `Contact` custom property is a relationship. CRM exposes the related person's stable `padma_id` and friendly name only when that person is also connected to the selected account.
- `add_contact_property` supports String custom writes. Existing Date, Integer, and Contact definitions remain readable but are not writable through that tool.

## Tags

- Tags (`tag_ids`) are free-form labels created by each school to organize or segment its contacts.
- Their names and meanings are defined by that school. A tag is not a standardized PADMA classification, so do not infer its meaning from its name alone.
- Discover current tags with `list_tags` before filtering. Use the returned IDs only in the same selected account.

## Marketing methods

- Marketing methods (`marketing_method_ids`) represent the school's marketing campaigns or acquisition methods, for example a specific campaign.
- Each school defines the methods it uses, so their names and exact scope are account-specific. Confirm the current values with `list_marketing_methods` before interpreting or filtering them.

## Contact lists

- Contact lists are saved groups of contacts that the school can reuse for segmentation.
- List membership is not equivalent to a contact status, tag, or marketing method. Use list filters only when the requested segment is explicitly defined by the saved list.
- Discover lists with `list_contact_lists`. Use intersection, union, or exclusion filters when combining list memberships in `search_contacts`.
- Use `get_contact_list` to execute one list with its persisted filters and ordering. Its saved UI columns control the returned property projection.
- A configured list column can remain visible without projecting a property when it is computed, operational, or stale.

## Contact history

- Contact history is the chronological activity feed for one contact. It can include communications, comments, enrollments, dropouts, sent campaigns, and tracked changes.
- It records activity; it is not a complete profile of the person's intent or circumstances. Keep conclusions tied to the returned entries and dates.

## Contact comments

- A comment is a new account-visible `FollowUp` entry attached to one contact.
- CRM records the authenticated user and current time. The agent supplies only the resolved contact and exact comment text.
- Repeating `add_contact_comment` creates another entry; comments are not idempotent.

## Communications

- A communication records an interaction with one existing contact in the selected account.
- CRM owns author attribution and sanitizes the supplied observations.
- `media` describes the channel; `incoming` describes its direction; `communicated_at` is the activity timestamp.
- Marketing methods are account-scoped acquisition or campaign references and must be discovered before use.
- `request_id` is an idempotency key scoped to the selected account. It is not a communication ID or contact identifier.

## Monthly statistics and lead funnel

- Monthly statistics are persisted account metrics with system-wide standardized definitions, names, and localized labels.
- The lead funnel aggregates persisted stages and transitions. It describes the account's stored commercial funnel data for the requested period; do not treat it as a full reconstruction of every contact's history.
