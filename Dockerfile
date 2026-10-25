# agentregistry (skills, prompts, agents, MCP) behind Caddy on one port, for Hostim.
FROM caddy:2.10 AS caddy

FROM ghcr.io/agentregistry-dev/agentregistry/server:v0.4.0

USER root
# git: the Skill controller pins sources with `git ls-remote`.
RUN apt-get update && apt-get install -y --no-install-recommends git openssh-client ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Registry API/UI and MCP stay on localhost; only Caddy (8000) is exposed.
ENV AGENT_REGISTRY_SERVER_ADDRESS=127.0.0.1:8080 \
    AGENT_REGISTRY_MCP_PORT=31313 \
    AGENT_REGISTRY_PLATFORM_MODE=docker \
    ADMIN_USER=admin

EXPOSE 8000
ENTRYPOINT []
CMD ["/start.sh"]
