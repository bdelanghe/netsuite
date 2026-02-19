# Contributing

## Setup

```shell
git clone https://github.com/bdelanghe/netsuite.git
cd netsuite
bundle install
```

## Tests

```shell
bundle exec rspec
```

Integration tests (live NetSuite calls) are opt-in:

```shell
NETSUITE_INTEGRATION=true bundle exec rspec
```

Coverage report:

```shell
COVERAGE=true bundle exec rspec
```

## Adding a new action

1. Create `lib/netsuite/actions/my_action.rb` inheriting `AbstractAction`
2. For async actions, `include AsyncResponse`
3. Register in `lib/netsuite/support/actions.rb`
4. Add autoload in `lib/netsuite.rb`
5. Add XML fixture in `spec/support/fixtures/my_action/`
6. Write spec in `spec/netsuite/actions/my_action_spec.rb`
