#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Optional: restore primary DB from a dump (e.g. sync local dev DB to production).
# Put a file at $DATABASE_PATH/restore.sql (or /data/restore.sql), then restart the machine.
if [ "$RAILS_ENV" = "production" ] && [ -f "${DATABASE_PATH:-/data}/restore.sql" ]; then
  sqlite3 "${DATABASE_PATH:-/data}/production.sqlite3" < "${DATABASE_PATH:-/data}/restore.sql"
  rm -f "${DATABASE_PATH:-/data}/restore.sql"
fi

# Run migrations in production (e.g. on Fly.io with volume-mounted SQLite).
# Fails boot on migration error so deploy does not serve with incompatible schema.
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails db:migrate
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
echo "$@"
exec "$@"
