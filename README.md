# Books.mtdr

Books in time.
Opinionated collections, insightful presentations.

## Usage

Server boot: `docker compose --profile web up`.
You may use `bin/server_local` shortcut.

Local access: <a href="http://localhost:3010/" target="_blank">http://localhost:3010/</a>

## Development

![rubyBadge](https://img.shields.io/badge/ruby-3.4.8-green)
![railsBadge](https://img.shields.io/badge/rails-8.1.1-green)

## Local setup

```sh
docker compose build shell
```

Shell container is the default for running all of the commands below.
You may use `bin/shell -e VAR_X=VAL_X COMMAND` shortcut.

### Code style checks:

```sh
pronto run
rubocop
yarn run eslint "app/javascript/**/*.{js,jsx}"
yarn run stylelint "app/assets/stylesheets/**/*.{css,scss}"
```

### Tests:

```sh
rspec
```

### Vulnerabilities:

```sh
bundler-audit --update
```

## Deployment (Fly.io)

Production uses SQLite on a Fly volume. Before the first deploy (or before deploying with the volume config), create the volume in the app region:

```sh
fly volumes create data --region fra --size 1
```

Then deploy. Migrations run automatically on app startup. To scale to more than one machine, create one volume per machine with the same name in the same region.

### Syncing local DB to production

To replace production data with your local development database:

1. **Dump local primary DB** to SQL (from project root, using the dev DB path):

   ```sh
   sqlite3 db/development.sqlite3 .dump > restore.sql
   ```

2. **Upload the dump** to the app volume on Fly (SFTP uses the mounted volume; the file must be named `restore.sql` so the entrypoint picks it up):

   ```sh
   fly ssh sftp shell
   # In the sftp prompt:
   put restore.sql /data/restore.sql
   bye
   ```

3. **Restart the machine** so the entrypoint runs again. It will restore from `/data/restore.sql` into the primary DB, remove the file, run migrations, then start the app:

   ```sh
   fly machine restart
   ```

   Or restart a specific machine: `fly machine list` then `fly machine restart <id>`.

This only syncs the **primary** database (`production.sqlite3`). The Solid Queue DB is separate; repeat with `production_solid_queue.sqlite3` and a different restore filename if you add support for it in the entrypoint.
