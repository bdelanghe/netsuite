# Configuration

## Token Based Authentication (recommended)

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
```

## WSDL and datacenter

This gem targets SOAP 2025.2 only. The WSDL defaults to the production URL for v2025_2_0.

```ruby
NetSuite.configure do
  reset!
  api_version '2025_2'

  # explicit WSDL URL (sandbox, specific datacenter, etc.)
  wsdl "https://webservices.sandbox.netsuite.com/wsdl/v2025_2_0/netsuite.wsdl"

  # or set just the domain and let the gem build the URL
  wsdl_domain "webservices.na2.netsuite.com"
end
```

## All options

```ruby
NetSuite.configure do
  reset!

  api_version   '2025_2'
  account       '12345'

  # auth (use TBA above instead)
  email         'email@domain.com'
  password      'password'
  role          1111

  # WSDL
  wsdl          "https://webservices.netsuite.com/wsdl/v2025_2_0/netsuite.wsdl"
  wsdl_domain   "webservices.na2.netsuite.com"

  # timeouts
  read_timeout  100_000

  # logging
  log           File.join(Rails.root, 'log/netsuite.log')
  # log_level   :debug

  # ignore read-only fields
  soap_header   'platformMsgs:preferences' => {
    'platformMsgs:ignoreReadOnlyFields' => true,
  }
end
```

Some configuration options mutate others. See `lib/netsuite/configuration.rb` for details.

## Multi-tenancy

For multiple NetSuite accounts in separate threads:

```ruby
# main thread
NetSuite.configure do
  multi_tenant!
end

# each child thread
NetSuite.configure do
  reset!
  account ENV['NETSUITE_ACCOUNT']
  # rest of config...
end
```

`multi_tenant!` is not affected by `reset!`.
