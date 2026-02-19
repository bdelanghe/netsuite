require 'spec_helper'

describe NetSuite::Actions::AsyncAddList do
  before { savon.mock! }
  after { savon.unmock! }

  context 'when record count exceeds the limit' do
    it 'raises ArgumentError for more than 400 records' do
      records = Array.new(401) { NetSuite::Records::Customer.new }
      expect { NetSuite::Actions::AsyncAddList.call(records) }.to raise_error(
        ArgumentError, /asyncAddList supports a maximum of 400 records/
      )
    end
  end

  context 'Customers' do
    let(:customers) do
      [
        NetSuite::Records::Customer.new(external_id: 'ext2', entity_id: 'Target', company_name: 'Target')
      ]
    end

    before do
      savon.expects(:async_add_list).with(:message =>
        {
          'record' => [{
            'listRel:entityId'    => 'Target',
            'listRel:companyName' => 'Target',
            '@xsi:type' => 'listRel:Customer',
            '@externalId' => 'ext2'
          }]
        }).returns(fixture('async_add_list/async_add_list_pending.xml'))
    end

    it 'makes a valid request to the NetSuite API' do
      NetSuite::Actions::AsyncAddList.call(customers)
    end

    it 'returns a valid Response object' do
      response = NetSuite::Actions::AsyncAddList.call(customers)
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
      expect(response.body[:job_id]).to eq('ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685')
      expect(response.body[:status]).to eq('pending')
    end
  end
end
