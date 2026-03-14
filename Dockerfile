FROM node:20-alpine

RUN apk add --no-cache git curl bash

# Install Shopify CLI globally
RUN npm install -g @shopify/cli

# Fake xdg-open: Alpine has no browser launcher. The CLI calls xdg-open to
# open the auth URL automatically; without this shim it crashes with ENOENT.
# The shim prints the URL so the user can open it manually, then exits 0
# so the CLI continues waiting for the OAuth callback.
RUN printf '#!/bin/sh\necho ""\necho "  → Open in your browser: $1"\necho ""\n' \
    > /usr/local/bin/xdg-open && chmod +x /usr/local/bin/xdg-open

# Pre-create .config dir with correct ownership before switching user
# (Docker volumes mount as root by default; this prevents EACCES errors)
RUN mkdir -p /home/node/.config && chown -R node:node /home/node

# Use existing non-root 'node' user (uid=1000)
USER node

WORKDIR /workspace

COPY --chown=node:node scripts/entrypoint.sh /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dev"]
