SHELL := /bin/bash
DB_USER ?= app
DB_PASS ?= app
DB_NAME ?= app
DB_HOST ?= localhost
DB_PORT ?= 5432

export PGPASSWORD=$(DB_PASS)

.PHONY: up down logs psql seed explain bench clean

up:
	docker compose -f ops/docker-compose.yml up -d

down:
	docker compose -f ops/docker-compose.yml down -v

logs:
	docker compose -f ops/docker-compose.yml logs -f db

psql:
	psql -h $(DB_HOST) -U $(DB_USER) -d $(DB_NAME)

seed:
	psql -h $(DB_HOST) -U $(DB_USER) -d $(DB_NAME) -f ops/scripts/seed.sql

explain:
	@if [ -n "$(QUERY)" ]; then \
		echo "Analyzing query: $(QUERY)"; \
		psql -h $(DB_HOST) -U $(DB_USER) -d $(DB_NAME) -c "EXPLAIN (ANALYZE, BUFFERS, VERBOSE) $$(cat $(QUERY))"; \
	else \
		echo "Usage: make explain QUERY=ops/scripts/queryN.sql"; \
		echo "Available queries:"; \
		ls -1 ops/scripts/query*.sql; \
	fi

bench:
	bash ops/scripts/bench.sh

clean:
	rm -rf .tmp || true
