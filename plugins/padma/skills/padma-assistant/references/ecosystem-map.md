# PADMA ecosystem for clients

PADMA is a modular suite for operating schools and boutique studios. Each product owns one business domain; using several products together does not merge their ownership or authorization.

## Source of truth

| Business question | Product | Available through companion plugin |
|---|---|---|
| Who can sign in and which organizations they may access | Accounts | Indirectly, through each MCP's OAuth grant |
| Who is the person and what is their relationship/status with a school | CRM | Yes, read-only |
| What communication data, including WhatsApp interactions, is recorded for a contact | CRM | Yes, read-only when exposed by CRM |
| How are contacts, commercial metrics, and lead funnels evolving | CRM | Yes, read-only |
| What income, expenses, movements, plans, and financial rules exist | Money | Yes, read and supported writes |
| What content, classes, bookings, or check-ins exist | Learn | No |
| Certificates, office stock/sales, manuals, or branded links | Specialized DeROSE Apps | No |

## Ownership rules

- Accounts owns identity and the organizational access context. An MCP's discovery tool exposes only the organizations usable by that OAuth session.
- CRM owns the contact-centered relationship, available communication data, and school-level commercial/pedagogical state.
- Money owns financial commitments, realized movements, classification, and financial reporting.
- Learn owns educational access and activity; Money plans do not determine learning access.

## Client-facing language

Speak in terms of the user's school, contacts, commercial activity, and finances. Avoid repository names, models, routes, ports, database IDs, or internal architecture unless the user explicitly asks as a developer.

When a requested domain is unavailable, identify the owning PADMA product and state that the available companion plugins connect only CRM and Money. Do not answer with guessed data from another product.
