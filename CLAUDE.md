# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Ruby gem for `netsuite-async-list`, wrapping the Oracle NetSuite SuiteTalk **SOAP Web Services API** via the Savon client. The `async-list` branch adds asynchronous bulk SOAP operations. **Note:** NetSuite is deprecating SOAP (final endpoint 2025.2, removed 2028.2). This gem is in maintenance mode.

## Commands

```bash
# Run all tests
bundle exec rspec
# or
bundle exec rake

# Run a single spec file
bundle exec rspec spec/netsuite/actions/async_add_list_spec.rb

# Run with coverage
bundle exec rake coverage

# Build the gem
bundle exec rake build
```

### Replaying a failed run
When CI (or a local run) fails, the RSpec seed is in the output (e.g. "Randomized with seed 12345"). Re-run with that seed to reproduce the same order:
```bash
bundle exec rspec --seed 12345
```
Use `bundle exec rspec --only-failures` to re-run only the examples that failed last time (requires `tmp/rspec_examples.txt` from a previous run).

There is no linter configured (no `.rubocop.yml`).

## Architecture

### Action Pattern
Each SOAP operation is a class under `NetSuite::Actions`. Actions inherit `AbstractAction` and implement `action_name` + `request_body`. The `Support::Requests` mixin provides the `call` class method and response wrapping. Each action also has an inner `Support::ClassMethods` module that gets `include`d into record classes via the `actions(...)` DSL.

### Async Operations (this branch)
Two-phase pattern:
1. **Submit** — `AsyncAddList.call(...)` returns `{ job_id:, status: 'pending' }`
2. **Poll** — `CheckAsyncStatus.call([job_id])`
3. **Fetch** — `GetAsyncResult.call([job_id, { page_index: 1 }])`

The `AsyncResponse` module (in `actions/async_response.rb`) is mixed into all async action classes; it overrides response parsing for the `asyncStatusResult`/`asyncResult` SOAP envelope shape.

### Record Composition
Record classes compose behavior via `include`:
- `Support::Fields` — `field`/`read_only_field`/`search_only_field` DSL
- `Support::Records` — `to_record` serialization (snake_case attrs → camelCase SOAP XML)
- `Support::Actions` — `actions(:get, :add, :async_add_list, ...)` DSL
- `Namespaces::*` — SOAP namespace module per record type (e.g. `ListRel`, `TranSales`)

### SOAP Endpoint
This gem targets **SOAP v2025.2** — the final supported NetSuite endpoint (removed in 2028.2).

There is no "current SOAP endpoint" stored in NetSuite. The endpoint you use is fully defined by **account ID + domain shard + SOAP version pinned in your code**. NetSuite doesn't choose this for you.

Endpoint formula: `https://<account_id>.<domain>/services/NetSuitePort_<version>`

Two config values pin the version:
- **`api_version '2025_2'`** — controls SOAP namespace URIs in request envelopes (enforced; no other value accepted)
- **`wsdl`** — WSDL Savon uses; local fixtures at `spec/support/fixtures/soap/v2025_2_0/`

Production setup:
```ruby
NetSuite.configure do
  account     ENV['NETSUITE_ACCOUNT']
  api_version '2025_2'
  wsdl        "https://#{ENV['NETSUITE_ACCOUNT']}.netsuite.com/wsdl/v2025_2_0/netsuite.wsdl"
end
```

To verify: search the codebase for `api_version` / `wsdl`, or inspect the `POST /services/NetSuitePort_2025_2` in Savon request logs. If the hostname contains `sb1`/`sb2`, you're on a sandbox shard.

### Configuration
`NetSuite::Configuration` is `extend self` (module singleton). Multi-tenancy is supported via `Thread.current` namespacing.

### Transport vs structure (Faraday migration)

**Faraday** and **Nokogiri** are orthogonal: Faraday = *how bytes move* (HTTP client); Nokogiri = *how documents are understood* (XML parse/query). Savon bundled both plus SOAP semantics, which hid control and coupled Rack. Replacing Savon means keeping that boundary clear:

- **Faraday**: open connection, POST body, return status + raw body. It does not care whether the body is XML or JSON.
- **Nokogiri**: parse `resp.body` (from Faraday, disk, or anywhere), XPath/CSS, serialize. It does not care where the document came from.

Flow: `resp = connection.post(...); doc = Nokogiri::XML(resp.body); parse(doc)`. No magic, no Rack, no SOAP abstraction leak. When adding a Faraday backend to `NetSuite::Client`, use Faraday for transport and Nokogiri only for request/response XML (build envelope, parse body into the same `#success?` / `#body` shape callers expect).

### Key Locations
- `lib/netsuite/client.rb` — single SOAP call boundary; today Savon, later swappable to Faraday + Nokogiri
- `lib/netsuite/actions/` — all SOAP operation classes (sync + async)
- `lib/netsuite/records/` — 200+ NetSuite record classes
- `lib/netsuite/support/` — shared mixins (`Fields`, `Actions`, `Records`, `Requests`, etc.)
- `lib/netsuite/configuration.rb` — Savon client config, auth, WSDL
- `spec/support/fixtures/` — XML fixture files for Savon mock responses, one directory per action

### Test Setup
Tests use RSpec 3 with Savon's `SpecHelper` to mock SOAP calls. Each action spec loads XML fixtures from `spec/support/fixtures/<action_name>/`.

## Adding a New Action

1. Create `lib/netsuite/actions/my_action.rb` inheriting `AbstractAction` (or an existing action for overrides)
2. For async actions, `include AsyncResponse`
3. Register in `lib/netsuite/support/actions.rb` (the `action(...)` DSL dispatch map)
4. Add autoload in `lib/netsuite.rb`
5. Add XML fixture in `spec/support/fixtures/my_action/`
6. Write spec in `spec/netsuite/actions/my_action_spec.rb`
