require 'spec_helper'

describe NetSuite::Actions::AsyncGetList do
  before { savon.mock! }
  after { savon.unmock! }

  context 'when record count exceeds the limit' do
    it 'raises ArgumentError for more than 2000 records' do
      ids = (1..2001).map(&:to_s)
      expect { NetSuite::Actions::AsyncGetList.call([NetSuite::Records::Customer, :list => ids]) }.to raise_error(
        ArgumentError, /asyncGetList supports a maximum of 2000 records/
      )
    end
  end

  context 'with valid record count' do
    let(:klass) { NetSuite::Records::Customer }
    let(:customer_list) { ['87', '176'] }

    before do
      savon.expects(:async_get_list).with(:message =>
        {
          :baseRef =>
            [
              {
                '@internalId' => '87',
                '@type'       => 'customer',
                '@xsi:type'   => 'platformCore:RecordRef'
              },
              {
                '@internalId' => '176',
                '@type'       => 'customer',
                '@xsi:type'   => 'platformCore:RecordRef'
              }
            ]
        }
      ).returns(fixture('async_get_list/async_get_list_pending.xml'))
    end

    it 'makes a valid request to the NetSuite API' do
      NetSuite::Actions::AsyncGetList.call([klass, :list => customer_list])
    end

    it 'returns a valid Response object' do
      response = NetSuite::Actions::AsyncGetList.call([klass, :list => customer_list])

      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
      expect(response.body[:job_id]).to eq('ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685')
    end
  end

  describe 'Support::ClassMethods' do
    let(:klass) do
      Class.new do
        include NetSuite::Actions::AsyncGetList::Support
      end
    end

    describe '#async_get_list' do
      context 'when the response is successful' do
        it 'returns the response body' do
          fake_response = double('response', success?: true, body: { job_id: 'JOB-1' })
          allow(NetSuite::Actions::AsyncGetList).to receive(:call).and_return(fake_response)
          expect(klass.async_get_list(list: ['1', '2'])).to eq({ job_id: 'JOB-1' })
        end
      end

      context 'when the response is unsuccessful' do
        it 'returns false' do
          allow(NetSuite::Actions::AsyncGetList).to receive(:call)
            .and_return(double('response', success?: false))
          expect(klass.async_get_list(list: ['1'])).to be false
        end
      end
    end
  end
end
