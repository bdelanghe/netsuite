module WebMockSoapHelper
  NETSUITE_SOAP_ENDPOINT = 'https://webservices.netsuite.com/services/NetSuitePort_2025_2'.freeze

  def stub_soap_response(xml)
    WebMock.stub_request(:post, NETSUITE_SOAP_ENDPOINT).to_return(
      status: 200,
      headers: { 'Content-Type' => 'text/xml; charset=utf-8' },
      body: xml
    )
  end
end

RSpec.configure do |config|
  config.include WebMockSoapHelper, :webmock_integration
end
