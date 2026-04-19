# Agent instructions

## Run environment-dependent commands through `bin/shell`

Use **`bin/shell`** to run shell commands in this repository (for example `bin/shell yarn install`, `bin/shell bundle exec rspec`).

**Why:** The project’s development environment runs in **Docker Compose** (`docker compose run … shell …`). The `bin/shell` script wraps that so commands execute with the same **Ruby, Node, system packages, and services** as the rest of the team and CI, instead of whatever happens to be installed on the host machine.

**Do not** assume bare `yarn`, `bundle`, `rails`, or `rspec` on the host match this app unless you have been told otherwise.
