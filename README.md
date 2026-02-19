[![Ruby](https://github.com/bdelanghe/netsuite/actions/workflows/main.yml/badge.svg)](https://github.com/bdelanghe/netsuite/actions/workflows/main.yml)
[![GitHub Package](https://img.shields.io/badge/github-packages-blue?logo=github)](https://github.com/bdelanghe/netsuite/packages)
![Coverage](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/bdelanghe/netsuite/badges/coverage.json)

# netsuite

Ruby gem for the NetSuite SuiteTalk SOAP API (v2025.2) with async bulk operations. Maintained fork of [NetSweet/netsuite](https://github.com/NetSweet/netsuite).

## Status

This gem targets **SOAP 2025.2** — the final supported endpoint. SOAP is removed from NetSuite in 2028.2. This gem exists to bridge existing integrations through that timeline; it is not for new projects.

| Release | What happens |
|---------|-------------|
| **2025.2** | Last planned SOAP endpoint |
| **2027.1** | Only 2025.2 supported |
| **2028.2** | SOAP removed entirely |

New integrations should use [SuiteTalk REST Web Services](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/chapter_1540391670.html) with OAuth 2.0.

## Install

Hosted on GitHub Packages, not RubyGems.org.

```ruby
# Gemfile
source "https://rubygems.pkg.github.com/bdelanghe" do
  gem "netsuite", "2025.2.1"
end
```

Or from the command line:

```shell
gem install netsuite --version "2025.2.1" --source "https://rubygems.pkg.github.com/bdelanghe"
```

Requires Ruby 3.1+.

## Quick start

```ruby
NetSuite.configure do
  reset!
  account       ENV['NETSUITE_ACCOUNT']
  api_version   '2025_2'
  consumer_key     ENV['NETSUITE_CONSUMER_KEY']
  consumer_secret  ENV['NETSUITE_CONSUMER_SECRET']
  token_id         ENV['NETSUITE_TOKEN_ID']
  token_secret     ENV['NETSUITE_TOKEN_SECRET']
end

customer = NetSuite::Records::Customer.get(4)
```

See [docs/configuration.md](docs/configuration.md) for all options (WSDL, sandbox, multi-tenancy, logging).

## Async bulk operations

For large operations, submit a job and poll for results rather than waiting on a single long-running request. See [docs/async.md](docs/async.md).

## Documentation

- [Configuration](docs/configuration.md) — WSDL, auth, sandbox, multi-tenancy
- [Async bulk operations](docs/async.md) — submit/poll/fetch pattern, available operations
- [Usage](docs/usage.md) — CRUD, search, custom records, null fields, files
- [Contributing](docs/contributing.md) — Testing, development setup

## Credits

Based on [NetSweet/netsuite](https://github.com/NetSweet/netsuite). Thanks to the original contributors.
