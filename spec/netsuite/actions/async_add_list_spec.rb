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

  context 'with internal_id (no external_id)' do
    let(:customers) do
      [NetSuite::Records::Customer.new(internal_id: '123', entity_id: 'Foo')]
    end

    before do
      savon.expects(:async_add_list).with(:message => {
        'record' => [{
          'listRel:entityId' => 'Foo',
          '@xsi:type'        => 'listRel:Customer',
          '@internalId'      => '123'
        }]
      }).returns(fixture('async_add_list/async_add_list_pending.xml'))
    end

    it 'includes @internalId in the request' do
      response = NetSuite::Actions::AsyncAddList.call(customers)
      expect(response).to be_success
    end
  end

  context 'with no internal_id or external_id' do
    let(:customers) do
      [NetSuite::Records::Customer.new(entity_id: 'NoId')]
    end

    before do
      savon.expects(:async_add_list).with(:message => {
        'record' => [{
          'listRel:entityId' => 'NoId',
          '@xsi:type'        => 'listRel:Customer'
        }]
      }).returns(fixture('async_add_list/async_add_list_pending.xml'))
    end

    it 'omits both @internalId and @externalId' do
      response = NetSuite::Actions::AsyncAddList.call(customers)
      expect(response).to be_success
    end
  end

  describe 'Support::ClassMethods' do
    let(:klass) do
      Class.new do
        include NetSuite::Actions::AsyncAddList::Support
        def initialize(attrs = {}); end
      end
    end

    describe '#async_add_list' do
      let(:record) { klass.new }

      context 'when the response is successful' do
        let(:fake_response) { double('response', success?: true, body: { job_id: 'JOB-1' }) }

        before { allow(NetSuite::Actions::AsyncAddList).to receive(:call).and_return(fake_response) }

        it 'returns the response body for pre-built instances' do
          expect(klass.async_add_list([record])).to eq({ job_id: 'JOB-1' })
        end

        it 'wraps raw attributes as instances using .new' do
          expect(klass.async_add_list([{ entity_id: 'Test' }])).to eq({ job_id: 'JOB-1' })
        end
      end

      context 'when the response is unsuccessful' do
        it 'returns false' do
          allow(NetSuite::Actions::AsyncAddList).to receive(:call)
            .and_return(double('response', success?: false))
          expect(klass.async_add_list([record])).to be false
        end
      end
    end
  end
end
