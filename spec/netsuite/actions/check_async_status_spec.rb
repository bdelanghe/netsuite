require 'spec_helper'

describe NetSuite::Actions::CheckAsyncStatus do
  before { savon.mock! }
  after  { savon.unmock! }

  let(:job_id) { 'WEBSERVICES_3392464_ASYNC_JOB_001' }

  context 'when status is pending' do
    before do
      savon.expects(:check_async_status)
           .with(message: { 'jobId' => job_id })
           .returns(File.read('spec/support/fixtures/check_async_status/check_async_status_pending.xml'))
    end

    subject(:response) { NetSuite::Actions::CheckAsyncStatus.call([job_id]) }

    it 'makes a valid request to the NetSuite API' do
      NetSuite::Actions::CheckAsyncStatus.call([job_id])
    end

    it 'returns a NetSuite::Response' do
      expect(response).to be_a(NetSuite::Response)
    end

    it 'is marked as successful' do
      expect(response).to be_success
    end

    it 'returns job_id as a String with the expected value' do
      expect(response.body[:job_id]).to be_a(String).and eq(job_id)
    end

    it 'returns status as a String equal to "pending"' do
      expect(response.body[:status]).to be_a(String).and eq('pending')
    end

    it 'returns percent_complete as a String equal to "0"' do
      expect(response.body[:percent_complete]).to be_a(String).and eq('0')
    end

    it 'returns est_remaining_duration as a String equal to "0"' do
      expect(response.body[:est_remaining_duration]).to be_a(String).and eq('0')
    end
  end

  context 'when status is complete' do
    before do
      savon.expects(:check_async_status)
           .with(message: { 'jobId' => job_id })
           .returns(File.read('spec/support/fixtures/check_async_status/check_async_status_complete.xml'))
    end

    subject(:response) { NetSuite::Actions::CheckAsyncStatus.call([job_id]) }

    it 'returns status as a String equal to "complete"' do
      expect(response.body[:status]).to be_a(String).and eq('complete')
    end

    it 'returns percent_complete as a String equal to "100"' do
      expect(response.body[:percent_complete]).to be_a(String).and eq('100')
    end
  end
end
