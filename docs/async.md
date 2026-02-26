# Async bulk operations

For large operations, submit a job and poll for results rather than waiting on a single long-running request.

## Pattern

```ruby
# 1. Submit
records = 100.times.map { |i| NetSuite::Records::Customer.new(entity_id: "Bulk-#{i}") }
result  = NetSuite::Records::Customer.async_add_list(records)
job_id  = result[:job_id]

# 2. Poll
status = NetSuite::Actions::CheckAsyncStatus.call([job_id])
sleep 2 until %w[finished failed].include?(status.body[:status])

# 3. Fetch (page_index is 1-based)
response = NetSuite::Actions::GetAsyncResult.call([job_id, 1])
```

## Available operations

| Operation | Max records |
|-----------|------------|
| `AsyncAddList` | 400 |
| `AsyncDeleteList` | 400 |
| `AsyncGetList` | 2000 |
| `AsyncUpdateList` | 200 |
| `AsyncUpsertList` | 200 |
| `AsyncSearch` | — |
| `AsyncInitializeList` | — |

## Enabling on a record class

Record classes opt in via the `actions` DSL:

```ruby
actions :add, :async_add_list, :update, :async_update_list
```

## Response shape

- `async_add_list` / `async_update_list` / `async_upsert_list` — `response.body[:write_response_list]`
- `async_delete_list` — `response.body[:delete_response_list]`
- `async_get_list` — `response.body[:read_response_list]`
- `async_search` — `response.body[:search_result]`
