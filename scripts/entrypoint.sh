#!/bin/bash
set -e

case "$1" in
  init)
    echo "→ Scaffolding new Shopify app..."
    cd /workspace
    shopify app init
    ;;
  dev)
    if [ ! -d "/workspace/app" ] || [ -z "$(ls -A /workspace/app 2>/dev/null)" ]; then
      echo "ERROR: App directory is empty. Run 'make init' first."
      exit 1
    fi
    echo "→ Starting Shopify dev server..."
    cd /workspace/app
    shopify app dev
    ;;
  *)
    exec "$@"
    ;;
esac
