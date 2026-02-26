require 'spec_helper'

describe NetSuite::Actions::AsyncSearch do
  before { savon.mock! }
  after { savon.unmock! }

  before do
    savon.expects(:async_search).with(:message => {
      'searchRecord' => {
        '@xsi:type'      => 'listRel:CustomerSearchAdvanced',
        '@savedSearchId' => 500,
        :content!        => { "listRel:criteria" => {} }
      },
    }).returns(fixture('async_search/async_search_pending.xml'))
  end

  it 'makes a valid request to the NetSuite API' do
    NetSuite::Actions::AsyncSearch.call([NetSuite::Records::Customer, { saved: 500 }])
  end

  it 'returns a valid Response object' do
    response = NetSuite::Actions::AsyncSearch.call([NetSuite::Records::Customer, { saved: 500 }])
    expect(response).to be_kind_of(NetSuite::Response)
    expect(response).to be_success
    expect(response.body[:status]).to eq('pending')
  end
end
