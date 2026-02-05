require 'spec_helper'

describe NetSuite::Actions::AsyncInitializeList do
  before { savon.mock! }
  after { savon.unmock! }

  let(:customer) { NetSuite::Records::Customer.new(:internal_id => 1) }

  before do
    savon.expects(:async_initialize_list).with(:message => {
      'platformMsgs:initializeRecord' => [
        {
          'platformCore:type' => 'customer',
          'platformCore:reference' => {},
          :attributes! => {
            'platformCore:reference' => {
              'internalId' => 1,
              :type        => 'customer'
            }
          }
        }
      ]
    }).returns(File.read('spec/support/fixtures/async_initialize_list/async_initialize_list_pending.xml'))
  end

  it 'makes a valid request to the NetSuite API' do
    NetSuite::Actions::AsyncInitializeList.call([
      { type: NetSuite::Records::Customer, reference: customer }
    ])
  end

  it 'returns a valid Response object' do
    response = NetSuite::Actions::AsyncInitializeList.call([
      { type: NetSuite::Records::Customer, reference: customer }
    ])
    expect(response).to be_kind_of(NetSuite::Response)
    expect(response).to be_success
    expect(response.body[:job_id]).to eq('ASYNCWEBSERVICES_563214_053120061943428686160042948_4bee0685')
  end
end
