require 'spec_helper'

# End-to-end contract test for the two-phase async lifecycle:
#   AsyncAddList.call  →  CheckAsyncStatus.call (pending)
#                      →  CheckAsyncStatus.call (complete)
#                      →  GetAsyncResult.call
#
# Key invariants verified:
#   1. job_id is a String threaded from submit response into every subsequent call
#   2. Status transitions from 'pending' to 'complete' across polls
#   3. Final result contains the expected write_response structure
describe 'async submit → poll → fetch lifecycle' do
  before { savon.mock! }
  after  { savon.unmock! }

  let(:customers) do
    [
      NetSuite::Records::Customer.new(external_id: 'ext1', entity_id: 'Shutter Fly', company_name: 'Shutter Fly, Inc.'),
      NetSuite::Records::Customer.new(external_id: 'ext2', entity_id: 'Target',      company_name: 'Target')
    ]
  end

  it 'threads job_id through the full lifecycle and reflects status transitions' do
    # ── Phase 1: Submit ────────────────────────────────────────────────────────
    savon.expects(:async_add_list)
         .with(message: {
           'record' => [
             {
               'listRel:entityId'    => 'Shutter Fly',
               'listRel:companyName' => 'Shutter Fly, Inc.',
               '@xsi:type'          => 'listRel:Customer',
               '@externalId'        => 'ext1'
             },
             {
               'listRel:entityId'    => 'Target',
               'listRel:companyName' => 'Target',
               '@xsi:type'          => 'listRel:Customer',
               '@externalId'        => 'ext2'
             }
           ]
         })
         .returns(File.read('spec/support/fixtures/async_add_list/async_add_list_customers.xml'))

    submit_response = NetSuite::Actions::AsyncAddList.call(customers)

    expect(submit_response).to be_a(NetSuite::Response)
    expect(submit_response).to be_success

    job_id = submit_response.body[:job_id]
    expect(job_id).to be_a(String)
    expect(job_id).to eq('WEBSERVICES_3392464_ASYNC_JOB_001')

    # ── Phase 2: Poll — pending ───────────────────────────────────────────────
    savon.expects(:check_async_status)
         .with(message: { 'jobId' => job_id })
         .returns(File.read('spec/support/fixtures/check_async_status/check_async_status_pending.xml'))

    pending_response = NetSuite::Actions::CheckAsyncStatus.call([job_id])

    expect(pending_response).to be_a(NetSuite::Response)
    expect(pending_response).to be_success
    expect(pending_response.body[:job_id]).to be_a(String).and eq(job_id)
    expect(pending_response.body[:status]).to be_a(String).and eq('pending')
    expect(pending_response.body[:percent_complete]).to be_a(String).and eq('0')

    # ── Phase 3: Poll — complete ──────────────────────────────────────────────
    savon.expects(:check_async_status)
         .with(message: { 'jobId' => job_id })
         .returns(File.read('spec/support/fixtures/check_async_status/check_async_status_complete.xml'))

    complete_response = NetSuite::Actions::CheckAsyncStatus.call([job_id])

    expect(complete_response.body[:status]).to be_a(String).and eq('complete')
    expect(complete_response.body[:percent_complete]).to be_a(String).and eq('100')

    # ── Phase 4: Fetch result ─────────────────────────────────────────────────
    savon.expects(:get_async_result)
         .with(message: { 'jobId' => job_id, 'pageIndex' => 1 })
         .returns(File.read('spec/support/fixtures/get_async_result/get_async_result_customers.xml'))

    result_response = NetSuite::Actions::GetAsyncResult.call([job_id])

    expect(result_response).to be_a(NetSuite::Response)
    expect(result_response).to be_success

    write_responses = Array(result_response.body[:write_response_list][:write_response])
    expect(write_responses).to be_an(Array)
    expect(write_responses.length).to eq(2)

    internal_ids = write_responses.map { |wr| wr[:base_ref][:@internal_id] }
    expect(internal_ids).to contain_exactly('979', '980')

    write_responses.each do |wr|
      expect(wr[:status][:@is_success]).to be_a(String).and eq('true')
      expect(wr[:base_ref][:@type]).to be_a(String).and eq('customer')
    end
  end
end
