require 'spec_helper'

describe NetSuite::Actions::GetAsyncResult do
  before { savon.mock! }
  after  { savon.unmock! }

  let(:job_id) { 'WEBSERVICES_3392464_ASYNC_JOB_001' }

  context 'fetching result for a completed asyncAddList job' do
    before do
      savon.expects(:get_async_result)
           .with(message: { 'jobId' => job_id, 'pageIndex' => 1 })
           .returns(File.read('spec/support/fixtures/get_async_result/get_async_result_customers.xml'))
    end

    subject(:response) { NetSuite::Actions::GetAsyncResult.call([job_id]) }

    it 'makes a valid request to the NetSuite API' do
      NetSuite::Actions::GetAsyncResult.call([job_id])
    end

    it 'returns a NetSuite::Response' do
      expect(response).to be_a(NetSuite::Response)
    end

    it 'is marked as successful' do
      expect(response).to be_success
    end

    it 'exposes the top-level status with a String @is_success attribute' do
      expect(response.body[:status]).to be_a(Hash)
      expect(response.body[:status][:@is_success]).to be_a(String).and eq('true')
    end

    it 'returns total_records as a String with the expected count' do
      expect(response.body[:total_records]).to be_a(String).and eq('2')
    end

    it 'returns write_response_list as a Hash' do
      expect(response.body[:write_response_list]).to be_a(Hash)
    end

    describe 'write_response entries' do
      subject(:write_responses) do
        Array(response.body[:write_response_list][:write_response])
      end

      it 'returns an Array of write_response hashes' do
        expect(write_responses).to be_an(Array)
        expect(write_responses.length).to eq(2)
      end

      it 'each write_response has a String @is_success status attribute' do
        write_responses.each do |wr|
          expect(wr[:status]).to be_a(Hash)
          expect(wr[:status][:@is_success]).to be_a(String).and eq('true')
        end
      end

      it 'each write_response has a base_ref with a String internalId' do
        write_responses.each do |wr|
          expect(wr[:base_ref]).to be_a(Hash)
          expect(wr[:base_ref][:@internal_id]).to be_a(String)
        end
      end

      it 'returns the expected internal IDs' do
        internal_ids = write_responses.map { |wr| wr[:base_ref][:@internal_id] }
        expect(internal_ids).to contain_exactly('979', '980')
      end

      it 'each base_ref has a String type attribute' do
        write_responses.each do |wr|
          expect(wr[:base_ref][:@type]).to be_a(String).and eq('customer')
        end
      end
    end
  end

  context 'with an explicit page_index' do
    before do
      savon.expects(:get_async_result)
           .with(message: { 'jobId' => job_id, 'pageIndex' => 2 })
           .returns(File.read('spec/support/fixtures/get_async_result/get_async_result_customers.xml'))
    end

    it 'sends the specified page index in the request' do
      NetSuite::Actions::GetAsyncResult.call([job_id, 2])
    end
  end
end
