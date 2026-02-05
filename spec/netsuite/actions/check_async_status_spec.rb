require 'spec_helper'

describe NetSuite::Actions::CheckAsyncStatus do
  before { savon.mock! }
  after { savon.unmock! }

  let(:job_id) { 'ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685' }

  before do
    savon.expects(:check_async_status).with(:message =>
      {
        'platformMsgs:jobId' => job_id
      }).returns(File.read('spec/support/fixtures/check_async_status/check_async_status_pending.xml'))
  end

  it 'makes a valid request to the NetSuite API' do
    NetSuite::Actions::CheckAsyncStatus.call([job_id])
  end

  it 'returns a valid Response object' do
    response = NetSuite::Actions::CheckAsyncStatus.call([job_id])
    expect(response).to be_kind_of(NetSuite::Response)
    expect(response).to be_success
    expect(response.body[:job_id]).to eq(job_id)
    expect(response.body[:status]).to eq('pending')
    expect(response.body[:percent_completed]).to eq('0.0')
    expect(response.body[:est_remaining_duration]).to eq('0.0')
  end
end
