# CRM monthly statistics

## Discover metrics

Call `list_monthly_stat_definitions` before selecting metrics by name. Use the returned stable `stat_name`, not a translated label. Definitions include localized label and description, `value_type`, whether the account has persisted data, and its first and last available months.

Read [monthly-stat-names.md](monthly-stat-names.md) for the system-wide meaning of every supported `stat_name`.

Availability describes persisted school-level records for the selected account. Teacher-level statistics and cross-account rankings are outside this plugin.

## Read series

Use `get_monthly_stats` with 1–20 `stat_names`. The default range is the 12 months ending with the current month; explicit ranges use strict `YYYY-MM` values and may span at most 36 months.

Series are dense: every requested month appears. A missing persisted record returns `value: null`, `unit: null`, and `updated_at: null`. Preserve that distinction:

- `null` means unknown or not persisted.
- `0` means a persisted zero value.
- Never calculate or fill a missing absolute value outside CRM.

## Calculate percentages from absolute values

Rate `stat_name` values are being deprecated. Do not request them. Request the documented absolute numerator and denominator together with `get_monthly_stats`, then calculate `numerator / denominator * 100` only when both returned values are non-null and the denominator is greater than zero.

For example, calculate the percentage of male students as `male_students / students * 100`. See [monthly-stat-names.md](monthly-stat-names.md) for every numerator/denominator pair. If either value is missing, or the denominator is zero, report the percentage as unavailable rather than zero.

## Compare periods

Use `compare_monthly_stats` instead of reproducing dashboard comparison logic. It returns:

- the selected month's current value;
- the previous month's persisted baseline;
- the average of the available prior three months;
- normalized delta and one of `improved`, `worsened`, `neutral`, or `missing`.

For a derived percentage, use the underlying absolute series to calculate each month's percentage. Do not request a deprecated rate name merely to obtain a server-generated comparison.

A prior-three-month average can use fewer than three records when some prior months are missing. State this limitation when it changes the interpretation.

## Lead funnel

Use `get_lead_funnel` to aggregate demand, visits, profile visits, and enrollments for a period. It returns stages with percent of initial demand and transitions with conversion percentages, without internal IDs or UI URLs.

Funnel aggregation can show zero when no persisted stage values contribute. If the difference between a true zero and missing source months matters, query the corresponding monthly series and disclose missing records.

Always state the selected account and date range. Never combine account funnels unless the user explicitly requests a clearly separated comparison of authorized accounts.
