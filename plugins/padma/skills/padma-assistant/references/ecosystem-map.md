# PADMA ecosystem for clients

PADMA is a modular suite for operating schools and boutique studios. Each product owns one business domain; using several products together does not merge their ownership or authorization.

## Source of truth

| Business question | Product | Available through this plugin |
|---|---|---|
| Who can sign in and which organizations they may access | Accounts | Indirectly, through each MCP's OAuth grant |
| Who is the person and what is their relationship/status with a school | CRM | Yes, read-only |
| How are contacts, commercial metrics, and lead funnels evolving | CRM | Yes, read-only |
| What income, expenses, movements, plans, and financial rules exist | Money | Yes, read and supported writes |
| What content, classes, bookings, or check-ins exist | Learn | No |
| What messages or WhatsApp sessions exist | WhatsApp service | No |
| Certificates, office stock/sales, manuals, or branded links | Specialized DeROSE Apps | No |

## Ownership rules

- Accounts owns identity and the organizational access context. An MCP's discovery tool exposes only the organizations usable by that OAuth session.
- CRM owns the contact-centered relationship and school-level commercial/pedagogical state.
- Money owns financial commitments, realized movements, classification, and financial reporting.
- Learn owns educational access and activity; Money plans do not determine learning access.
- Communication services enable contact workflows but do not replace CRM as relationship owner.

## Client-facing language

Speak in terms of the user's school, contacts, commercial activity, and finances. Avoid repository names, models, routes, ports, database IDs, or internal architecture unless the user explicitly asks as a developer.

When a requested domain is unavailable, identify the owning PADMA product and state that this plugin currently connects only CRM and Money. Do not answer with guessed data from another product.
