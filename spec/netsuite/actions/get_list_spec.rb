require 'spec_helper'

describe NetSuite::Actions::GetList do
  before { savon.mock! }
  after  { savon.unmock! }

  let(:customer_class) { NetSuite::Records::Customer }
  let(:internal_id)    { '979' }

  describe 'request body' do
    before do
      savon.expects(:get_list).with(:message =>
        {
          baseRef: [{
            '@internalId' => internal_id,
            '@type'       => 'customer',
            '@xsi:type'   => 'platformCore:RecordRef'
          }]
        }).returns(fixture('get_list/get_list_customers.xml'))
    end

    it 'sends the correct SOAP message' do
      NetSuite::Actions::GetList.call([customer_class, [internal_id]])
    end
  end

  describe 'single record response' do
    before do
      savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customers.xml'))
    end

    it 'returns a successful Response' do
      response = NetSuite::Actions::GetList.call([customer_class, [internal_id]])
      expect(response).to be_kind_of(NetSuite::Response)
      expect(response).to be_success
    end

    it 'wraps a single record in an array' do
      response = NetSuite::Actions::GetList.call([customer_class, [internal_id]])
      expect(response.body).to be_an(Array)
      expect(response.body.length).to eq(1)
    end

    it 'returns the record data' do
      response = NetSuite::Actions::GetList.call([customer_class, [internal_id]])
      record = response.body.first
      expect(record[:status][:@is_success]).to be_a(String).and eq('true')
      expect(record[:record][:@internal_id]).to be_a(String).and eq('979')
    end
  end

  describe 'multiple records response' do
    before do
      savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customers_multiple.xml'))
    end

    it 'returns a successful Response' do
      response = NetSuite::Actions::GetList.call([customer_class, ['979', '980']])
      expect(response).to be_success
    end

    it 'returns an array with all records' do
      response = NetSuite::Actions::GetList.call([customer_class, ['979', '980']])
      expect(response.body).to be_an(Array)
      expect(response.body.length).to eq(2)
    end

    it 'contains data for each record' do
      response = NetSuite::Actions::GetList.call([customer_class, ['979', '980']])
      expect(response.body[0][:record][:@internal_id]).to eq('979')
      expect(response.body[1][:record][:@internal_id]).to eq('980')
    end
  end

  describe 'error response' do
    before do
      savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customer_error.xml'))
    end

    it 'returns an unsuccessful Response' do
      response = NetSuite::Actions::GetList.call([customer_class, ['999']])
      expect(response).not_to be_success
    end

    it 'status is_success is false' do
      response = NetSuite::Actions::GetList.call([customer_class, ['999']])
      expect(response.body.first[:status][:@is_success]).to be_a(String).and eq('false')
    end
  end

  describe 'allow_incomplete option' do
    context 'with a mix of success and failure' do
      before do
        savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customers_multiple.xml'))
      end

      it 'succeeds when allow_incomplete: true and at least one record succeeds' do
        response = NetSuite::Actions::GetList.call([customer_class, { list: ['979', '980'], allow_incomplete: true }])
        expect(response).to be_success
      end
    end

    context 'when all records fail' do
      before do
        savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customer_error.xml'))
      end

      it 'fails even with allow_incomplete: true when no records succeed' do
        response = NetSuite::Actions::GetList.call([customer_class, { list: ['999'], allow_incomplete: true }])
        expect(response).not_to be_success
      end
    end
  end

  describe 'Customer.get_list class method' do
    context 'when successful' do
      before do
        savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customers.xml'))
      end

      it 'returns an array of Customer instances' do
        customers = customer_class.get_list(['979'])
        expect(customers).to be_an(Array)
        expect(customers.length).to eq(1)
        expect(customers.first).to be_kind_of(customer_class)
      end

      it 'maps entity_id from the record' do
        customers = customer_class.get_list(['979'])
        expect(customers.first.entity_id).to eq('Test Customer')
      end
    end

    context 'when unsuccessful' do
      before do
        savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customer_error.xml'))
      end

      it 'returns false' do
        result = customer_class.get_list(['999'])
        expect(result).to be false
      end
    end

    context 'with multiple records' do
      before do
        savon.expects(:get_list).with(message: :any).returns(fixture('get_list/get_list_customers_multiple.xml'))
      end

      it 'returns all Customer instances' do
        customers = customer_class.get_list(['979', '980'])
        expect(customers.length).to eq(2)
        expect(customers).to all(be_kind_of(customer_class))
      end
    end
  end
end
