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
end
