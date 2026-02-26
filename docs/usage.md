# Usage

## CRUD

```ruby
# get
customer = NetSuite::Records::Customer.get(4)

# get list
customers = NetSuite::Records::Customer.get_list(list: [4, 5, 6])

# add
task = NetSuite::Records::Task.new(
  title: 'Follow up',
  assigned: NetSuite::Records::RecordRef.new(internal_id: 12345),
  due_date: DateTime.now + 1,
  message: 'Take care of this'
)
task.add

# update
task.update(message: 'New message')

# delete
task.delete

# refresh after add
task.refresh
```

## Search

```ruby
# basic
search = NetSuite::Records::Customer.search(
  basic: [
    { field: 'companyName', operator: 'contains', value: 'Acme' }
  ]
)

# with pagination
search = NetSuite::Records::Customer.search(
  criteria: {
    basic: [{ field: 'isInactive', value: false }]
  },
  preferences: { page_size: 10 }
)

search.results_in_batches do |batch|
  puts batch.map(&:internal_id)
end

# custom records
NetSuite::Records::CustomRecord.search(
  basic: [
    {
      field: 'recType',
      operator: 'is',
      value: NetSuite::Records::CustomRecordRef.new(internal_id: 10),
    }
  ]
).results

# saved search
NetSuite::Records::Customer.search(
  saved: 500,
  basic: [
    { field: 'entityId', operator: 'hasKeywords', value: 'Assumption' }
  ]
).results

# joins
NetSuite::Records::SalesOrder.search(
  criteria: {
    basic: [
      { field: 'type', operator: 'anyOf', value: ['_salesOrder'] },
      { field: 'status', operator: 'anyOf', value: ['_salesOrderPendingApproval'] },
    ],
    accountJoin: [
      { field: 'internalId', operator: 'noneOf', value: [NetSuite::Records::Account.new(internal_id: 215)] }
    ]
  }
)
```

## Custom records and fields

```ruby
# custom fields — you must set ALL custom fields, not just the ones you're updating
contact = NetSuite::Records::Contact.get(12345)
contact.custom_field_list.custentity_alistfield = { internal_id: 1 }
contact.custom_field_list.custentity_abooleanfield = true
contact.update(custom_field_list: contact.custom_field_list)

# custom record get
record = NetSuite::Records::CustomRecord.get(type_id: 10, internal_id: 100)

# custom record add
record = NetSuite::Records::CustomRecord.new
record.rec_type = NetSuite::Records::CustomRecord.new(internal_id: 10)
record.custom_field_list.custrecord_locationstate = "New Jersey"
record.add
```

## Null fields

```ruby
invoice = NetSuite::Records::Invoice.get(12345)
invoice.update(null_field_list: 'shipMethod')
invoice.update(null_field_list: ['shipAddressList', 'shipMethod'])
```

## Files

```ruby
file = NetSuite::Records::File.new(
  content: Base64.encode64(File.read('/path/to/file')),
  name: 'Invoice.pdf',
)
file.add

invoice = NetSuite::Records::Invoice.get(internal_id: 1)
invoice.attach_file(NetSuite::Records::RecordRef.new(internal_id: file.internal_id))
```

## Select values

```ruby
NetSuite::Records::BaseRefList.get_select_value(
  recordType: 'serviceSaleItem',
  field: 'taxSchedule'
)
```

## Deleted records

```ruby
response = NetSuite::Records::LotNumberedInventoryItem.get_deleted(
  criteria: [
    { field: 'type', operator: 'anyOf', value: 'lotNumberedInventoryItem' }
  ]
)
```

## Raw SOAP calls

```ruby
NetSuite::Configuration.connection.call :get_server_time
```
