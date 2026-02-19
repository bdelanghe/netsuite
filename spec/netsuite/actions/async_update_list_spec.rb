require 'spec_helper'

describe NetSuite::Actions::AsyncUpdateList do
  before { savon.mock! }
  after { savon.unmock! }

  context 'when record count exceeds the limit' do
    it 'raises ArgumentError for more than 200 records' do
      records = Array.new(201) { NetSuite::Records::InventoryItem.new }
      expect { NetSuite::Actions::AsyncUpdateList.call(records) }.to raise_error(
        ArgumentError, /asyncUpdateList supports a maximum of 200 records/
      )
    end
  end

  context 'Items' do
    let(:items) do
      [
        NetSuite::Records::InventoryItem.new(internal_id: '624113', item_id: 'Target', upccode: 'Target')
      ]
    end

    before do
      savon.expects(:async_update_list).with(:message =>
        {
          'record' => [{
            'listAcct:itemId' => 'Target',
            '@xsi:type' => 'listAcct:InventoryItem',
            '@internalId' => '624113'
          }]
        }).returns(fixture('async_update_list/async_update_list_pending.xml'))
    end

    it 'makes a valid request to the NetSuite API' do
      NetSuite::Actions::AsyncUpdateList.call(items)
    end

    it 'returns a valid Response object' do
      response = NetSuite::Actions::AsyncUpdateList.call(items)
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
      expect(response.body[:job_id]).to eq('ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685')
    end
  end
end
