#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid


# Optional: restore primary DB from a dump (e.g. sync local dev DB to production).
# Remove existing DB first so the dump replaces it entirely (avoids UNIQUE constraint on schema_migrations).
database_path="${DATABASE_PATH:-/data}"
autoload_file="${DATABASE_AUTOLOAD_FILENAME:-to_load.sql}"
database_name="${DATABASE_NAME:-production}"
if [ "$DATABASE_DUMP_AUTOLOAD" = "true" ] && [ -f "${database_path}/${autoload_file}" ]; then
  rm -f "${database_path}/${database_name}.sqlite3"
  sqlite3 "${database_path}/${database_name}.sqlite3" < "${database_path}/${autoload_file}"
  rm -f "${database_path}/${autoload_file}"
fi

# Auto-run migrations in production.
# Fails boot on migration error so deploy does not serve with incompatible schema.
run_migrations="${RUN_MIGRATIONS:-false}"
if [ "$run_migrations" = "true" ]; then
  bundle exec rails db:migrate
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
