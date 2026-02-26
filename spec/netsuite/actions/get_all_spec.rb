require 'spec_helper'

describe NetSuite::Actions::GetAll do
  before { savon.mock! }
  after  { savon.unmock! }

  context 'SalesTaxItem' do
    before do
      savon.expects(:get_all)
           .with(message: { record: [{ record_type: 'salesTaxItem' }] })
           .returns(File.read('spec/support/fixtures/get_all/get_all_sales_tax_items.xml'))
    end

    subject(:response) { NetSuite::Actions::GetAll.call([NetSuite::Records::SalesTaxItem]) }

    it 'makes a valid request to the NetSuite API' do
      NetSuite::Actions::GetAll.call([NetSuite::Records::SalesTaxItem])
    end

    it 'returns a NetSuite::Response' do
      expect(response).to be_a(NetSuite::Response)
    end

    it 'is successful' do
      expect(response).to be_success
    end

    it 'returns the records as an Array' do
      expect(response.body).to be_an(Array)
      expect(response.body.length).to eq(2)
    end

    it 'derives the record type name from the class name' do
      # SalesTaxItem → salesTaxItem (lowercases the first character)
      expect(response.body.first).to be_a(Hash)
    end
  end

  context 'action_name derivation' do
    it 'lowercases the first character of the class name for the record type' do
      action = NetSuite::Actions::GetAll.allocate
      action.instance_variable_set(:@klass, NetSuite::Records::SalesTaxItem)
      body = action.send(:request_body)
      expect(body[:record].first[:record_type]).to eq('salesTaxItem')
    end

    it 'handles single-word class names' do
      action = NetSuite::Actions::GetAll.allocate
      action.instance_variable_set(:@klass, NetSuite::Records::Currency)
      body = action.send(:request_body)
      expect(body[:record].first[:record_type]).to eq('currency')
    end
  end

  context 'nil-safe response_hash (edge cases)' do
    it 'raises when the outer key is missing (no safe navigation — documents current behavior)' do
      action = NetSuite::Actions::GetAll.allocate
      action.instance_variable_set(:@response, double(body: {}))
      expect { action.send(:response_hash) }.to raise_error(NoMethodError)
    end
  end
end
