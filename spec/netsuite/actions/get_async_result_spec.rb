require 'spec_helper'

describe NetSuite::Actions::GetAsyncResult do
  before { savon.mock! }
  after { savon.unmock! }

  let(:job_id) { 'ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685' }

  before do
    savon.expects(:get_async_result).with(:message =>
      {
        'platformMsgs:jobId' => job_id,
        'platformMsgs:pageIndex' => 1
      }).returns(File.read('spec/support/fixtures/get_async_result/get_async_result_finished.xml'))
  end

  it 'makes a valid request to the NetSuite API' do
    NetSuite::Actions::GetAsyncResult.call([job_id, { page_index: 1 }])
  end

  it 'returns a valid Response object' do
    response = NetSuite::Actions::GetAsyncResult.call([job_id, { page_index: 1 }])
    expect(response).to be_kind_of(NetSuite::Response)
    expect(response).to be_success
    expect(response.body[:job_id]).to eq(job_id)
    expect(response.body[:status]).to eq('finished')
    expect(response.body[:write_response_list]).not_to be_nil
  end
end
