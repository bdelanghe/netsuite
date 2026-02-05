require 'spec_helper'

describe NetSuite::Actions::AsyncUpsertList do
  before { savon.mock! }
  after { savon.unmock! }

  context 'Customers' do
    context 'one customer' do
      let(:customers) do
        [
          NetSuite::Records::Customer.new(external_id: 'ext2', entity_id: 'Target', company_name: 'Target')
        ]
      end

      before do
        savon.expects(:async_upsert_list).with(:message =>
          {
            'record' => [{
              'listRel:entityId'    => 'Target',
              'listRel:companyName' => 'Target',
              '@xsi:type' => 'listRel:Customer',
              '@externalId' => 'ext2'
            }]
          }).returns(File.read('spec/support/fixtures/async_upsert_list/async_upsert_list_one_customer.xml'))
      end

      it 'makes a valid request to the NetSuite API' do
        NetSuite::Actions::AsyncUpsertList.call(customers)
      end

      it 'returns a valid Response object' do
        response = NetSuite::Actions::AsyncUpsertList.call(customers)
        expect(response).to be_kind_of(NetSuite::Response)
        expect(response).to be_success
        expect(response.body[:job_id]).to eq('123')
      end
    end

    context 'two customers' do
      let(:customers) do
        [
          NetSuite::Records::Customer.new(external_id: 'ext1', entity_id: 'Shutter Fly', company_name: 'Shutter Fly, Inc.'),
          NetSuite::Records::Customer.new(external_id: 'ext2', entity_id: 'Target', company_name: 'Target')
        ]
      end

      before do
        savon.expects(:async_upsert_list).with(:message =>
          {
            'record' => [{
                'listRel:entityId'    => 'Shutter Fly',
                'listRel:companyName' => 'Shutter Fly, Inc.',
                '@xsi:type' => 'listRel:Customer',
                '@externalId' => 'ext1'
              },
              {
                'listRel:entityId'    => 'Target',
                'listRel:companyName' => 'Target',
                '@xsi:type' => 'listRel:Customer',
                '@externalId' => 'ext2'
              }
            ]
          }).returns(File.read('spec/support/fixtures/async_upsert_list/async_upsert_list_customers.xml'))
      end

      it 'makes a valid request to the NetSuite API' do
        NetSuite::Actions::AsyncUpsertList.call(customers)
      end

      it 'returns a valid Response object' do
        response = NetSuite::Actions::AsyncUpsertList.call(customers)
        expect(response).to be_kind_of(NetSuite::Response)
        expect(response).to be_success
        expect(response.body[:job_id]).to eq('456')
      end
    end
  end

  context 'with errors' do
    let(:customers) do
      [
        NetSuite::Records::Customer.new(external_id: 'ext1-bad', entity_id: 'Shutter Fly', company_name: 'Shutter Fly, Inc.'),
        NetSuite::Records::Customer.new(external_id: 'ext2-bad', entity_id: 'Target', company_name: 'Target')
      ]
    end

    before do
      savon.expects(:async_upsert_list).with(:message =>
        {
          'record' => [{
            'listRel:entityId'    => 'Shutter Fly',
            'listRel:companyName' => 'Shutter Fly, Inc.',
            '@xsi:type' => 'listRel:Customer',
            '@externalId' => 'ext1-bad'
          },
          {
            'listRel:entityId'    => 'Target',
            'listRel:companyName' => 'Target',
            '@xsi:type' => 'listRel:Customer',
            '@externalId' => 'ext2-bad'
          }
          ]
        }).returns(File.read('spec/support/fixtures/async_upsert_list/async_upsert_list_with_errors.xml'))
    end

    it 'constructs error objects' do
      response = NetSuite::Actions::AsyncUpsertList.call(customers)
      expect(response.errors.first.code).to eq('USER_ERROR')
      expect(response.errors.first.message).to eq('Please enter value(s) for: Item')
      expect(response.errors.first.type).to eq('ERROR')
    end
  end
end
