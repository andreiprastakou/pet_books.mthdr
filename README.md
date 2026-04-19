# Books.mtdr

Books in time.
Opinionated collections, insightful presentations.

## Usage

Server boot: `docker compose --profile web up` (starts Rails and **Shakapacker** dev server on port **3035**).
You may use `bin/server_local` shortcut.

Local access: <a href="http://localhost:3010/" target="_blank">http://localhost:3010/</a>

## Development

![rubyBadge](https://img.shields.io/badge/ruby-4.0.2-green)
![railsBadge](https://img.shields.io/badge/rails-8.1.3-green)

### Local setup

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

Make sure you have FLY_API_TOKEN set and flyctl installed (https://fly.io/docs/flyctl/install/).

Deploy command:
```sh
fly deploy
```

### Syncing local DB to production

Preset values on fly deployment:

* DATABASE_DUMP_AUTOLOAD=1
* DATABASE_AUTOLOAD_FILENAME=to_load.sql

```sh
sqlite3 db/development.sqlite3 .dump > to_load.sql
fly ssh sftp shell
put to_load.sql /data/to_load.sql
fly machine restart
```

### Syncing production DB to local

```sh
cp db/development.sqlite3 db/development.sqlite3.bak
fly ssh console -C "sqlite3 /data/production.sqlite3 .dump" > production_dump.sql
bin/shell sh -c "rm -f db/development.sqlite3 && sqlite3 db/development.sqlite3 < production_dump.sql"
```
