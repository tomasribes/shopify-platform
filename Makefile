.PHONY: build init dev down clean

# Build the Docker image
build:
	docker compose build

# First-time setup: scaffold the Shopify app (interactive)
init:
	docker compose run --rm -it shopify init

# Start development server with hot reload
dev:
	docker compose up shopify

# Stop all containers
down:
	docker compose down

# Remove containers, volumes, and built images
clean:
	docker compose down -v --rmi local
