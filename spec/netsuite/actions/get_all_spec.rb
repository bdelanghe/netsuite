require 'spec_helper'

describe NetSuite::Actions::GetAll do
  before { savon.mock! }
  after  { savon.unmock! }

  let(:currency_class) { NetSuite::Records::Currency }

  describe 'request body' do
    before do
      savon.expects(:get_all).with(message: {
        record: [{ record_type: 'currency' }]
      }).returns(fixture('get_all/get_all_currencies.xml'))
    end

    it 'sends the correct record type' do
      NetSuite::Actions::GetAll.call([currency_class])
    end
  end

  describe 'successful response' do
    before do
      savon.expects(:get_all).with(message: :any).returns(fixture('get_all/get_all_currencies.xml'))
    end

    it 'returns a successful Response' do
      response = NetSuite::Actions::GetAll.call([currency_class])
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
    end

    it 'returns an array of record attribute hashes' do
      response = NetSuite::Actions::GetAll.call([currency_class])
      expect(response.body).to be_an(Array)
      expect(response.body.length).to eq(2)
    end

    it 'includes record data' do
      response = NetSuite::Actions::GetAll.call([currency_class])
      expect(response.body.first[:name]).to eq('US Dollar')
      expect(response.body.first[:"@internal_id"]).to eq('1')
      expect(response.body.last[:name]).to eq('Euro')
      expect(response.body.last[:"@internal_id"]).to eq('2')
    end
  end

  describe 'error response' do
    before do
      savon.expects(:get_all).with(message: :any).returns(fixture('get_all/get_all_error.xml'))
    end

    it 'returns an unsuccessful Response' do
      response = NetSuite::Actions::GetAll.call([currency_class])
      expect(response).not_to be_success
    end

    it 'returns nil body' do
      response = NetSuite::Actions::GetAll.call([currency_class])
      expect(response.body).to be_nil
    end
  end

  describe 'Currency.get_all class method' do
    context 'when successful' do
      before do
        savon.expects(:get_all).with(message: :any).returns(fixture('get_all/get_all_currencies.xml'))
      end

      it 'returns an array of Currency instances' do
        currencies = currency_class.get_all
        expect(currencies).to be_an(Array)
        expect(currencies.length).to eq(2)
        expect(currencies).to all(be_kind_of(currency_class))
      end

      it 'maps record fields onto instances' do
        currencies = currency_class.get_all
        expect(currencies.first.name).to eq('US Dollar')
        expect(currencies.last.name).to eq('Euro')
      end

      it 'sets internal_id on each instance' do
        currencies = currency_class.get_all
        expect(currencies.first.internal_id).to eq('1')
        expect(currencies.last.internal_id).to eq('2')
      end
    end

    context 'when unsuccessful' do
      before do
        savon.expects(:get_all).with(message: :any).returns(fixture('get_all/get_all_error.xml'))
      end

      it 'returns false' do
        result = currency_class.get_all
        expect(result).to be false
      end
    end
  end
end
