#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DB_USER=${DB_USER:-app}
DB_PASS=${DB_PASS:-app}
DB_NAME=${DB_NAME:-app}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
export PGPASSWORD="$DB_PASS"

# Find all query files
QUERY_FILES=("$SCRIPT_DIR"/query*.sql)

if [ ${#QUERY_FILES[@]} -eq 0 ] || [ ! -f "${QUERY_FILES[0]}" ]; then
  echo "Error: No query files found in $SCRIPT_DIR" >&2
  exit 1
fi

echo "═══════════════════════════════════════════════════════════════"
echo "Database Performance Benchmark"
echo "Found ${#QUERY_FILES[@]} queries to test"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Function to benchmark a single query file
bench_query_file() {
  local query_file=$1
  local query_name=$(basename "$query_file" .sql)
  
  # Extract description from file
  local desc=$(head -1 "$query_file" | sed 's/^-- *//')
  
  echo "─────────────────────────────────────────────────────────────"
  echo "$desc"
  echo "─────────────────────────────────────────────────────────────"
  
  # Warmup
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$query_file" > /dev/null 2>&1 || true
  
  # Run 3 times and collect timings
  for i in 1 2 3; do
    echo -n "Run #$i: "
    result=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
      -c '\timing on' \
      -f "$query_file" 2>&1 | grep "^Time:" | awk '{print $2" "$3}')
    echo "$result"
  done
  echo ""
}

# Benchmark each query
for query_file in "${QUERY_FILES[@]}"; do
  if [ -f "$query_file" ]; then
    bench_query_file "$query_file"
  fi
done

echo "═══════════════════════════════════════════════════════════════"
echo "Benchmark Complete"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "To analyze a specific query execution plan:"
echo "  make explain QUERY=ops/scripts/queryN.sql"
echo ""
echo "Compare baseline performance and test your optimizations."
