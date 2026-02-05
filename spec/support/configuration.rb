RSpec.configure do |config|
  config.before do
    NetSuite.configure do
      reset!
      email    'me@example.com'
      password 'myPassword'
      account  1234
      # Keep tests offline by using the local WSDL fixture.
      wsdl     File.expand_path('2015.wsdl', __dir__)
    end
  end
end
