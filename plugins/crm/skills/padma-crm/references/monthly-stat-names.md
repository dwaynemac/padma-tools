# CRM monthly stat names

`stat_name` values are standardized system-wide. This reference documents every non-rate name currently accepted by `Statistics::MonthlyStat::VALID_NAMES` in CRM. Rate names are being deprecated and are intentionally excluded; calculate percentages from the absolute values below instead. Use `list_monthly_stat_definitions` for the selected account's localized label and persisted availability; an available name can still have no data for that account or month.

All counts refer to the reference month unless stated otherwise.

## Student population

| `stat_name` | Represents |
|---|---|
| `students` | Students at the end of the reference month. |
| `male_students` | Students whose recorded gender is male. |
| `female_students` | Students whose recorded gender is female. |
| `students_average_age` | Average age of students. |
| `students_cycle_duration` | Median number of days that recently dropped-out students remained as students. |
| `in_professional_training` | Students marked as in professional training. |
| `in_person_students` | Students with in-person access. |
| `live_students` | Students with live/online access. |
| `standard_students` | Students with the `standard` filiation tier. |
| `lite_students` | Students with the `lite` filiation tier. |
| `count_students_0_25` | Students aged from 0 through 25, inclusive. |
| `count_students_0_35` | Students aged from 0 through 35, inclusive. |

## Student levels

| `stat_name` | Represents |
|---|---|
| `aspirante_students` | Students at the Aspirante level. |
| `sadhaka_students` | Students at the Sádhaka level. |
| `yogin_students` | Students at the Yôgin level. |
| `chela_students` | Students at the Chêla level. |
| `graduado_students` | Students at the Graduado level. |
| `assistant_students` | Students at the Asistente level. |
| `professor_students` | Students at the Docente level. |
| `master_students` | Students at the Maestro level. |

## Enrollments and dropouts

| `stat_name` | Represents |
|---|---|
| `enrollments` | Enrollments recorded in the month. |
| `male_enrollments` | Enrollments recorded in the month for contacts whose recorded gender is male. |
| `in_person_enrollments` | Enrollments recorded in the month with in-person access. |
| `live_enrollments` | Enrollments recorded in the month with live/online access. |
| `dropouts` | Dropouts recorded in the month. |
| `in_person_drop_outs` | Dropouts recorded in the month with in-person access. |
| `live_drop_outs` | Dropouts recorded in the month with live/online access. |
| `dropouts_beginners` | Dropouts recorded in the month at the Aspirante level. |
| `dropouts_intermediates` | Dropouts recorded in the month at Sádhaka level or above. |

## Visits and enrollment effectiveness

| `stat_name` | Represents |
|---|---|
| `interviews` | Visits recorded in the month. |
| `male_interviews` | Visits recorded in the month for contacts whose recorded gender is male. |
| `female_interviews` | Visits recorded in the month for contacts whose recorded gender is female. |
| `p_interviews` | Visits with a P coefficient, including P-, Perfil, and P+. |
| `male_p_interviews` | P-coefficient visits for contacts whose recorded gender is male. |
| `fp_interviews` | Visits with an FP coefficient. |
| `unknown_interviews` | Visits without a recognized coefficient. |
| `trial_p_interviews` | Trial lessons with a P coefficient. |
| `trial_enrollment_count` | Profile trial lessons that resulted in an enrollment. |

## Demand and communications

| `stat_name` | Represents |
|---|---|
| `demand` | Unique contacts with an incoming communication in the month. |
| `male_demand` | Unique male contacts with an incoming communication in the month. |
| `female_demand` | Unique female contacts with an incoming communication in the month. |
| `emails` | Unique contacts with an incoming email in the month. |
| `phonecalls` | Unique contacts with an incoming phone call in the month. |
| `website_contact` | Unique contacts with an incoming website contact in the month. |
| `messaging_comms` | Unique contacts with an incoming messaging contact in the month. |
| `social_comms` | Unique contacts with an incoming social-media contact in the month. |
| `televisits` | Unique contacts with an incoming remote communication: email, phone call, website, messaging, or social media. |
| `conversion_count` | Remote-communication contacts that also had a visit in the month. |

## Deprecated rate names and replacement calculations

Do not request these rate names. Request the absolute names in the formula and calculate `numerator / denominator * 100` only when both values are present and the denominator is greater than zero.

| Deprecated `stat_name` | Replacement calculation |
|---|---|
| `male_students_rate` | `male_students / students * 100` |
| `students_0_35_rate` | `count_students_0_35 / students * 100` |
| `aspirante_students_rate` | `aspirante_students / students * 100` |
| `sadhaka_students_rate` | `sadhaka_students / students * 100` |
| `yogin_students_rate` | `yogin_students / students * 100` |
| `chela_students_rate` | `chela_students / students * 100` |
| `dropout_rate` | `dropouts / (students + dropouts) * 100` |
| `beginners_dropout_rate` | `dropouts_beginners / (aspirante_students + dropouts_beginners) * 100` |
| `swasthya_dropout_rate` | `dropouts_intermediates / (intermediate_students + dropouts_intermediates) * 100`, where `intermediate_students` is the same month's sum of `sadhaka_students`, `yogin_students`, `chela_students`, `graduado_students`, `assistant_students`, `professor_students`, and `master_students` |
| `male_interviews_rate` | `male_interviews / interviews * 100` |
| `female_interviews_rate` | `female_interviews / interviews * 100` |
| `enrollment_rate` | `enrollments / p_interviews * 100` |
| `male_enrollment_rate` | `male_enrollments / male_p_interviews * 100` |
| `trial_enrollment_rate` | `trial_enrollment_count / trial_p_interviews * 100` |
| `male_demand_rate` | `male_demand / demand * 100` |
| `female_demand_rate` | `female_demand / demand * 100` |
| `conversion_rate` | `conversion_count / televisits * 100` |

## Interpretation notes

- Gender-based metrics use the contact's recorded gender; they do not infer gender from a name or other data.
- Counts for communications and demand are distinct contacts, not the total number of messages or calls.
- A percentage with a zero or missing denominator is unavailable. Preserve MCP's returned `null` for absolute values; do not substitute zero.
