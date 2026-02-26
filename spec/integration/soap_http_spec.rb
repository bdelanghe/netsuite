require 'spec_helper'

# WebMock-based integration tests: exercises the full Savon stack (request
# serialization + real HTTP POST stub + response XML parsing) without using
# savon.mock!. This differs from the unit specs in that Savon builds the real
# SOAP envelope and processes the real HTTP response bytes.
#
# Tagged :webmock_integration so WebMockSoapHelper is included automatically.
describe 'SOAP HTTP Integration', :webmock_integration do
  let(:job_id) { 'ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685' }

  describe 'AsyncAddList via HTTP' do
    let(:customers) do
      [NetSuite::Records::Customer.new(external_id: 'ext2', entity_id: 'Target', company_name: 'Target')]
    end

    before do
      stub_soap_response(fixture('async_add_list/async_add_list_pending.xml'))
    end

    it 'builds a real SOAP envelope and parses the response' do
      response = NetSuite::Actions::AsyncAddList.call(customers)
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
    end

    it 'returns the job_id from the parsed XML body' do
      response = NetSuite::Actions::AsyncAddList.call(customers)
      expect(response.body[:job_id]).to be_a(String).and eq(job_id)
    end

    it 'returns pending status from the parsed XML body' do
      response = NetSuite::Actions::AsyncAddList.call(customers)
      expect(response.body[:status]).to be_a(String).and eq('pending')
    end
  end

  describe 'CheckAsyncStatus via HTTP' do
    before do
      stub_soap_response(fixture('check_async_status/check_async_status_pending.xml'))
    end

    it 'builds a real SOAP envelope and parses the response' do
      response = NetSuite::Actions::CheckAsyncStatus.call([job_id])
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
    end

    it 'returns job_id and pending status from the parsed XML body' do
      response = NetSuite::Actions::CheckAsyncStatus.call([job_id])
      expect(response.body[:job_id]).to be_a(String).and eq(job_id)
      expect(response.body[:status]).to be_a(String).and eq('pending')
      expect(response.body[:percent_completed]).to be_a(String).and eq('0.0')
      expect(response.body[:est_remaining_duration]).to be_a(String).and eq('0.0')
    end
  end

  describe 'GetAsyncResult via HTTP' do
    before do
      stub_soap_response(fixture('get_async_result/get_async_result_finished.xml'))
    end

    it 'builds a real SOAP envelope and parses the response' do
      response = NetSuite::Actions::GetAsyncResult.call([job_id, 1])
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
    end

    it 'returns finished status and write_response_list from the parsed XML body' do
      response = NetSuite::Actions::GetAsyncResult.call([job_id, 1])
      expect(response.body[:job_id]).to be_a(String).and eq(job_id)
      expect(response.body[:status]).to be_a(String).and eq('finished')
      expect(response.body[:write_response_list]).to be_a(Hash)
    end
  end
end
