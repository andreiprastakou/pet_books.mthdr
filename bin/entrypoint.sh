#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Run migrations in production (e.g. on Fly.io with volume-mounted SQLite).
# Fails boot on migration error so deploy does not serve with incompatible schema.
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails db:migrate
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
echo "$@"
exec "$@"
