require 'spec_helper'

# End-to-end test of the async submit → poll → fetch lifecycle.
# Uses Savon SpecHelper (same pattern as other action specs) and the existing
# fixture files so no new XML is needed.
describe 'Async Lifecycle: submit → poll → fetch' do
  before { savon.mock! }
  after  { savon.unmock! }

  let(:job_id) { 'ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685' }
  let(:customer) { NetSuite::Records::Customer.new(external_id: 'ext2', entity_id: 'Target', company_name: 'Target') }

  it 'threads job_id through AsyncAddList → CheckAsyncStatus → GetAsyncResult' do
    # Phase 1: Submit
    savon.expects(:async_add_list).with(:message => {
      'record' => [{
        'listRel:entityId'    => 'Target',
        'listRel:companyName' => 'Target',
        '@xsi:type'           => 'listRel:Customer',
        '@externalId'         => 'ext2'
      }]
    }).returns(fixture('async_add_list/async_add_list_pending.xml'))

    submit_response = NetSuite::Actions::AsyncAddList.call([customer])
    expect(submit_response).to be_success
    submitted_job_id = submit_response.body[:job_id]
    expect(submitted_job_id).to be_a(String).and eq(job_id)

    # Phase 2: Poll
    savon.expects(:check_async_status).with(:message => {
      'platformMsgs:jobId' => submitted_job_id
    }).returns(fixture('check_async_status/check_async_status_pending.xml'))

    poll_response = NetSuite::Actions::CheckAsyncStatus.call([submitted_job_id])
    expect(poll_response).to be_success
    expect(poll_response.body[:job_id]).to be_a(String).and eq(submitted_job_id)
    expect(poll_response.body[:status]).to be_a(String).and eq('pending')

    # Phase 3: Fetch result (using the finished fixture)
    savon.expects(:get_async_result).with(:message => {
      'platformMsgs:jobId'     => submitted_job_id,
      'platformMsgs:pageIndex' => 1
    }).returns(fixture('get_async_result/get_async_result_finished.xml'))

    fetch_response = NetSuite::Actions::GetAsyncResult.call([submitted_job_id, 1])
    expect(fetch_response).to be_success
    expect(fetch_response.body[:job_id]).to be_a(String).and eq(submitted_job_id)
    expect(fetch_response.body[:status]).to be_a(String).and eq('finished')
    expect(fetch_response.body[:write_response_list]).to be_a(Hash)
  end
end
