# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Ruby gem wrapping the Oracle NetSuite SuiteTalk **SOAP Web Services API** via the Savon client. The `async-list` branch adds asynchronous bulk SOAP operations. **Note:** NetSuite is deprecating SOAP (final endpoint 2025.2, removed 2028.2). This gem is in maintenance mode.

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

# Integration tests (makes live NetSuite calls)
NETSUITE_INTEGRATION=true bundle exec rspec

# Build the gem
bundle exec rake build
```

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

### Configuration
`NetSuite::Configuration` is `extend self` (module singleton). Multi-tenancy is supported via `Thread.current` namespacing.

### Key Locations
- `lib/netsuite/actions/` — all SOAP operation classes (sync + async)
- `lib/netsuite/records/` — 200+ NetSuite record classes
- `lib/netsuite/support/` — shared mixins (`Fields`, `Actions`, `Records`, `Requests`, etc.)
- `lib/netsuite/configuration.rb` — Savon client config, auth, WSDL
- `spec/support/fixtures/` — XML fixture files for Savon mock responses, one directory per action

### Test Setup
Tests use RSpec 3 with Savon's `SpecHelper` to mock SOAP calls. Each action spec loads XML fixtures from `spec/support/fixtures/<action_name>/`. Integration tests are tagged `:integration` and skipped unless `NETSUITE_INTEGRATION=true`.

## Adding a New Action

1. Create `lib/netsuite/actions/my_action.rb` inheriting `AbstractAction` (or an existing action for overrides)
2. For async actions, `include AsyncResponse`
3. Register in `lib/netsuite/support/actions.rb` (the `action(...)` DSL dispatch map)
4. Add autoload in `lib/netsuite.rb`
5. Add XML fixture in `spec/support/fixtures/my_action/`
6. Write spec in `spec/netsuite/actions/my_action_spec.rb`
