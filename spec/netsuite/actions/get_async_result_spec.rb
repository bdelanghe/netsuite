require 'spec_helper'

describe NetSuite::Actions::GetAsyncResult do
  before { savon.mock! }
  after  { savon.unmock! }

  let(:job_id)     { 'ASYNCWEBSERVICES_123456_SB1_000000000000000000000000000_0000000' }
  let(:page_index) { 1 }

  shared_examples 'a valid GetAsyncResult response' do
    it 'makes a valid request to the NetSuite API' do
      NetSuite::Actions::GetAsyncResult.call([job_id, page_index])
    end

    it 'returns a successful Response' do
      response = NetSuite::Actions::GetAsyncResult.call([job_id, page_index])
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
    end

    it 'returns the job_id and finished status' do
      response = NetSuite::Actions::GetAsyncResult.call([job_id, page_index])
      expect(response.body[:job_id]).to eq(job_id)
      expect(response.body[:status]).to eq('finished')
    end
  end

  context 'with a single write response' do
    before do
      savon.expects(:get_async_result).with(:message => {
        'platformMsgs:jobId'     => job_id,
        'platformMsgs:pageIndex' => page_index
      }).returns(File.read('spec/support/fixtures/get_async_result/get_async_result_upsert_list_finished.xml'))
    end

    include_examples 'a valid GetAsyncResult response'

    it 'returns a write_response_list with the record ref' do
      response = NetSuite::Actions::GetAsyncResult.call([job_id, page_index])
      write_response = response.body[:write_response_list][:write_response]

      expect(write_response[:status][:@is_success]).to eq('true')
      expect(write_response[:status][:status_detail][:after_submit_failed]).to eq(false)

      base_ref = write_response[:base_ref]
      expect(base_ref[:@type]).to eq('cashSale')
      expect(base_ref[:@external_id]).to eq('ext1')
      expect(base_ref[:@internal_id]).to eq('100001')
    end
  end

  context 'with multiple write responses' do
    let(:job_id) { 'ASYNCWEBSERVICES_123456_SB1_000000000000000000000000000_0000001' }

    before do
      savon.expects(:get_async_result).with(:message => {
        'platformMsgs:jobId'     => job_id,
        'platformMsgs:pageIndex' => page_index
      }).returns(File.read('spec/support/fixtures/get_async_result/get_async_result_write_list_multiple.xml'))
    end

    include_examples 'a valid GetAsyncResult response'

    it 'returns a write_response_list with all record refs' do
      response = NetSuite::Actions::GetAsyncResult.call([job_id, page_index])
      write_responses = response.body[:write_response_list][:write_response]

      expect(write_responses).to be_an(Array)
      expect(write_responses.length).to eq(2)

      expect(write_responses[0][:base_ref][:@external_id]).to eq('ext1')
      expect(write_responses[0][:base_ref][:@internal_id]).to eq('100001')

      expect(write_responses[1][:base_ref][:@external_id]).to eq('ext2')
      expect(write_responses[1][:base_ref][:@internal_id]).to eq('100002')
    end
  end
end
