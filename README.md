# Books.mtdr

Books in time.
Opinionated collections, insightful presentations.

## Setup

```sh
docker compose run shell
```

## Usage

Server boot: `docker compose --profile web up`.
You may use `bin/server_local` shortcut.

Local access: <a href="http://localhost:3010/" target="_blank">http://localhost:3010/</a>

## Development

![rubyBadge](https://img.shields.io/badge/ruby-3.4.8-green)
![railsBadge](https://img.shields.io/badge/rails-8.1.1-green)

Shell container is the default for running all of the commands below.
You may use `bin/shell -e VAR_X=VAL_X COMMAND` shortcut.

Code style checks:

```sh
pronto run
rubocop
yarn run eslint "app/javascript/**/*.{js,jsx}"
yarn run stylelint "app/assets/stylesheets/**/*.{css,scss}"
```

Tests:

```sh
rspec
```

Vulnerabilities:

```sh
bundler-audit --update
```
