# Single SOAP fixtures path; do not add other versioned soap fixture trees.
SOAP_FIXTURES_ROOT     = File.expand_path('fixtures/soap/v2025_2_0', __dir__).freeze
NETSUITE_WSDL_FIXTURE  = File.join(SOAP_FIXTURES_ROOT, 'wsdl/netsuite.wsdl').freeze
NETSUITE_FIXTURES_DIR  = File.expand_path('fixtures', __dir__).freeze

RSpec.configure do |config|
  config.include(Module.new do
    def fixture(path)
      File.read(File.join(NETSUITE_FIXTURES_DIR, path))
    end
  end)

  config.before do
    NetSuite.configure do
      reset!
      email       'me@example.com'
      password    'myPassword'
      account     1234
      api_version '2025_2'
      wsdl        NETSUITE_WSDL_FIXTURE
    end
  end
end
