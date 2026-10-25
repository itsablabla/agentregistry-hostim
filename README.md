# agentregistry on Hostim

Self-hosted [agentregistry](https://github.com/agentregistry-dev/agentregistry) v0.4.0 (skills, prompts, agents, MCP server catalog, built-in MCP server) behind Caddy on a single port.

- `/` - web UI and REST API (`/v0/...`)
- `/mcp` - registry MCP server (streamable HTTP)
- `/healthz` - unauthenticated health check

Auth: every path except `/healthz` requires either `Authorization: Bearer $REGISTRY_TOKEN` or HTTP basic auth (`ADMIN_USER` / `ADMIN_PASSWORD`).

Required environment variables: `REGISTRY_TOKEN`, `ADMIN_PASSWORD`, `AGENT_REGISTRY_DATABASE_URL`.
