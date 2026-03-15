#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

env_name="${ENV_NAME:-production}"

# Optional: restore primary DB from a dump (e.g. sync local dev DB to production).
# Remove existing DB first so the dump replaces it entirely (avoids UNIQUE constraint on schema_migrations).
database_path="${DATABASE_PATH:-/data}"
autoload_file="${DATABASE_AUTOLOAD_FILENAME:-to_load.sql}"
if [ "$env_name" = "production" ] && [ -f "${database_path}/${autoload_file}" ] && [ "$DATABASE_DUMP_AUTOLOAD" = "1" ]; then
  rm -f "${database_path}/${env_name}.sqlite3"
  sqlite3 "${database_path}/${env_name}.sqlite3" < "${database_path}/${autoload_file}"
  rm -f "${database_path}/${autoload_file}"
fi

# Run migrations in production (e.g. on Fly.io with volume-mounted SQLite).
# Fails boot on migration error so deploy does not serve with incompatible schema.
if [ "$env_name" = "production" ]; then
  bundle exec rails db:migrate
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
echo "$@"
exec "$@"
