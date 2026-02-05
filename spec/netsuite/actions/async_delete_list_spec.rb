require 'spec_helper'

describe NetSuite::Actions::AsyncDeleteList do
  before { savon.mock! }
  after { savon.unmock! }

  let(:klass) { NetSuite::Records::Customer }
  let(:customer) do
    NetSuite::Records::Customer.new(:internal_id => '1', :entity_id => 'Customer', :company_name => 'Customer')
  end

  let(:other_customer) do
    NetSuite::Records::Customer.new(:internal_id => '2', :entity_id => 'Other_Customer', :company_name => 'Other Customer')
  end

  let(:customer_list) { [customer.internal_id, other_customer.internal_id] }

  before do
    savon.expects(:async_delete_list).with(:message =>
      {
        :baseRef =>
          [
            {
              '@internalId' => customer.internal_id,
              '@type'       => 'customer',
              '@xsi:type'   => 'platformCore:RecordRef'
            },
            {
              '@internalId' => other_customer.internal_id,
              '@type'       => 'customer',
              '@xsi:type'   => 'platformCore:RecordRef'
            }
          ]
      }
    ).returns(File.read('spec/support/fixtures/async_delete_list/async_delete_list_pending.xml'))
  end

  it 'makes a valid request to the NetSuite API' do
    NetSuite::Actions::AsyncDeleteList.call([klass, :list => customer_list])
  end

  it 'returns a valid Response object' do
    response = NetSuite::Actions::AsyncDeleteList.call([klass, :list => customer_list])

    expect(response).to be_kind_of(NetSuite::Response)
    expect(response).to be_success
    expect(response.body[:status]).to eq('pending')
  end
end
