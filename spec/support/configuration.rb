NETSUITE_WSDL_FIXTURE = File.expand_path('fixtures/soap/v2021_1_0/wsdl/netsuite.wsdl', __dir__).freeze

RSpec.configure do |config|
  config.before do
    NetSuite.configure do
      reset!
      email    'me@example.com'
      password 'myPassword'
      account  1234
      wsdl     NETSUITE_WSDL_FIXTURE
    end
  end
end
