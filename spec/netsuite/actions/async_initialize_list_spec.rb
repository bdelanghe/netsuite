require 'spec_helper'

describe NetSuite::Actions::AsyncInitializeList do
  before { savon.mock! }
  after { savon.unmock! }

  let(:customer) { NetSuite::Records::Customer.new(:internal_id => 1) }

  context 'SOAP requests' do
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
      }).returns(fixture('async_initialize_list/async_initialize_list_pending.xml'))
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

  describe '#normalize_entry (private)' do
    let(:instance) { NetSuite::Actions::AsyncInitializeList.allocate }

    context 'Array entry' do
      it 'returns [klass, object] unchanged' do
        entry = [NetSuite::Records::Customer, customer]
        klass, obj = instance.send(:normalize_entry, entry)
        expect(klass).to eq(NetSuite::Records::Customer)
        expect(obj).to eq(customer)
      end
    end

    context 'Hash entry with :klass key' do
      it 'extracts klass from :klass' do
        entry = { klass: NetSuite::Records::Customer, reference: customer }
        klass, obj = instance.send(:normalize_entry, entry)
        expect(klass).to eq(NetSuite::Records::Customer)
        expect(obj).to eq(customer)
      end
    end

    context 'Hash entry with :record_type key' do
      it 'extracts klass from :record_type' do
        entry = { record_type: NetSuite::Records::Customer, object: customer }
        klass, obj = instance.send(:normalize_entry, entry)
        expect(klass).to eq(NetSuite::Records::Customer)
        expect(obj).to eq(customer)
      end
    end

    context 'invalid entry type' do
      it 'raises ArgumentError' do
        expect { instance.send(:normalize_entry, 'invalid') }
          .to raise_error(ArgumentError, /initialize list entries must be an Array or Hash/)
      end
    end
  end

  describe 'Support::ClassMethods' do
    let(:klass) do
      Class.new do
        include NetSuite::Actions::AsyncInitializeList::Support
      end
    end

    describe '#async_initialize_list' do
      context 'when the response is successful' do
        it 'returns the response body' do
          fake_response = double('response', success?: true, body: { job_id: 'JOB-1' })
          allow(NetSuite::Actions::AsyncInitializeList).to receive(:call).and_return(fake_response)
          expect(klass.async_initialize_list([])).to eq({ job_id: 'JOB-1' })
        end
      end

      context 'when the response is unsuccessful' do
        it 'returns false' do
          allow(NetSuite::Actions::AsyncInitializeList).to receive(:call)
            .and_return(double('response', success?: false))
          expect(klass.async_initialize_list([])).to be false
        end
      end
    end
  end
end
