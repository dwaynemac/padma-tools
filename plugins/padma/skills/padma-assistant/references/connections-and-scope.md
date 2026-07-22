# Connections and organizational scope

## MCP connections

| Server | Resource | Required scope | First proof call |
|---|---|---|---|
| `crm` | `https://crm.derose.app/mcp` | `openid profile account crm` | CRM `list_accounts` |
| `money` | `https://money.derose.app/mcp` | `openid profile account money` | Money `list_businesses` |

Both servers use PADMA Accounts OAuth, Dynamic Client Registration, and PKCE. The client manages credentials; do not configure a shared Client ID or Client Secret. The token audience must exactly match its MCP resource, including scheme, hostname, and `/mcp`.

Each server has its own OAuth grant and resource. A successful CRM login does not authorize Money, and vice versa. Login/configuration alone is not live verification: require the first proof call and at least one contextual tool call.

## Independent selectors

CRM uses stable `account_name`. Money uses the integer `business_id` returned by `list_businesses`. These values belong to different public contracts.

- With one authorized organization, each MCP can usually select it automatically.
- With several, explicitly select from the discovery response or ask the user.
- Never pass a CRM selector to Money or a Money ID to CRM.
- Similar display names are not proof that two tenants represent the same organization.
- Do not probe names or IDs not returned by discovery.

## Availability and authorization

- Missing tools: start a new task after installing or updating the plugin, then reconnect the affected MCP.
- `401`: reconnect the affected server and verify its exact resource URL.
- `403` or `forbidden`: refresh discovery and authorization; do not probe other tenants.
- `429`: wait for `Retry-After` instead of looping.
- `503`: Accounts could not validate the credential; retry later without treating the grant as rejected.
- Intended organization absent from discovery: reconnect that product and authorize the required account.

If one MCP is unavailable during a combined request, continue only when the remaining product can answer a useful, clearly partial result. State what could not be verified.
