# Learn activity summary

`get_contact_learn_activity_summary` returns the latest snapshot calculated by Learn and stored by CRM for the selected account-contact relationship. CRM normalizes numeric and boolean types but does not recalculate these values.

Use `calculated_at` as the snapshot time. Activity may have changed after that timestamp.

## Scope

The fields do not all use the same scope:

- `live_and_in_person_checkins_last_30_days_count` counts non-copy live and in-person check-ins for the selected account during the previous 30 days.
- Frequency, cancellation, and last-activity fields are calculated from the user's Learn activity across schools, not only the selected CRM account.
- Live and on-demand last-activity lookups include reposted content. The frequency calculation excludes copied check-ins and check-ins made on the user's own timer.

Do not compare the account-scoped count directly with the cross-school deltas as if they described the same population.

## Fields

| Field | Meaning |
|---|---|
| `live_and_in_person_checkins_last_30_days_count` | Selected-account live and in-person check-ins during the previous 30 days, excluding copied check-ins. |
| `checkin_freq_delta` | Recent weekly check-in frequency divided by historical weekly frequency. Recent means 3 weeks; historical means 13 weeks and includes those recent weeks. |
| `checkin_freq_delta_flag` | `true` only when `checkin_freq_delta < 0.5`. |
| `last_minute_cancellation_ratio_delta` | Recent last-minute-cancellation ratio divided by the historical ratio. Both ratios include no-shows as last-minute cancellations. Recent means 3 weeks; historical means 13 weeks. Bookings enter each window according to their creation time. |
| `cancellation_flag` | `true` only when `last_minute_cancellation_ratio_delta > 1.5`. |
| `last_live_or_in_person_checkin_at` | Latest live or in-person check-in known by Learn, in UTC ISO 8601; may be `null`. |
| `live_checkin_flag` | `true` when that latest check-in exists and is more than 14 days old. |
| `last_ondemand_checkin_at` | Latest on-demand check-in known by Learn, in UTC ISO 8601; may be `null`. |
| `ondemand_checkin_flag` | `true` when that latest check-in exists and is more than 10 days old. |
| `last_seen_flag` | `true` only when both `live_checkin_flag` and `ondemand_checkin_flag` are `true`. A missing activity timestamp does not activate it. |
| `churn_risk` | Logical OR of `checkin_freq_delta_flag`, `cancellation_flag`, and `last_seen_flag`. |
| `churn_risk_reasons` | Exact active reasons: `checkin_freq_delta`, `cancellation`, and/or `last_seen`. |
| `calculated_at` | Time Learn calculated the snapshot, in UTC ISO 8601. |

## Interpret deltas as ratios

A delta describes the recent value relative to its historical value:

- `1.0` means recent and historical values are equal.
- `0.42` means the recent value is 42% of the historical value, a 58% decrease.
- `1.5` means the recent value is 150% of the historical value, a 50% increase.

Do not call `0.42` a decrease of 0.42 points or 42 percentage points. The cancellation delta is a ratio between two cancellation ratios, not the recent cancellation percentage itself.

When the historical denominator is zero, Learn returns a delta of `1` as a neutral fallback. In that case, do not infer that recent activity or cancellations were present or absent from the delta alone.

Thresholds are strict: exactly `0.5` does not activate `checkin_freq_delta_flag`, and exactly `1.5` does not activate `cancellation_flag`.

## Churn-risk boundary

Treat `churn_risk` as an activity signal calculated by Learn, not a diagnosis or certainty that the student will leave.

The summary does not include subscription or payment status. Learn's separate churn-risk job can add the `learn-churn-risk` CRM tag because of subscription state even when the summary's `churn_risk` is `false`; do not use the tag as evidence that one of the summary flags is active.
