require 'spec_helper'

describe NetSuite::Records::CustomerAddressbook do
  # address schema changed in 2014.2; both branches are covered below.

  let(:attributes) do
    {
      :addressbook => {
        :addressbook_address => NetSuite::Records::Address.new({
                                  :addr1        => '123 Happy Lane',
                                  :addr_text    => "123 Happy Lane\nLos Angeles CA 90007",
                                  :city         => 'Los Angeles',
                                  :country      => '_unitedStates',
                                  :state        => 'CA',
                                  :override     => false,
                                  :zip          => '90007'
                                    }),
        :default_billing  => true,
        :default_shipping => true,
        :internal_id      => '567',
        :is_residential   => false,
        :label            => '123 Happy Lane'
      }
    }
  end

  let(:list) { NetSuite::Records::CustomerAddressbook.new(attributes) }

  it 'has all the right fields' do
    [
      :default_billing, :default_shipping, :internal_id,
               :is_residential, :label
    ].each do |field|
      expect(list).to have_field(field)
    end

    expect(list.addressbook_address).to_not be_nil
  end

  describe '#initialize' do
    context 'when taking in a hash of attributes' do
      it 'sets the attributes for the object given the attributes hash' do
        expect(list.addressbook_address.addr1).to eql('123 Happy Lane')
        expect(list.addressbook_address.addr_text).to eql("123 Happy Lane\nLos Angeles CA 90007")
        expect(list.addressbook_address.city).to eql('Los Angeles')
        expect(list.addressbook_address.country.to_record).to eql('_unitedStates')
        expect(list.addressbook_address.override).to be_falsey
        expect(list.addressbook_address.state).to eql('CA')
        expect(list.addressbook_address.zip).to eql('90007')
        expect(list.default_billing).to be_truthy
        expect(list.default_shipping).to be_truthy
        expect(list.is_residential).to be_falsey
        expect(list.label).to eql('123 Happy Lane')
        expect(list.internal_id).to eql('567')
      end
    end

    context 'when taking in a CustomerAddressbookList instance' do
      it 'sets the attributes for the object given the record attributes' do
        old_list = NetSuite::Records::CustomerAddressbook.new(attributes)
        list     = NetSuite::Records::CustomerAddressbook.new(old_list)
        expect(list.addressbook_address.addr1).to eql('123 Happy Lane')
        expect(list.addressbook_address.addr_text).to eql("123 Happy Lane\nLos Angeles CA 90007")
        expect(list.addressbook_address.city).to eql('Los Angeles')
        expect(list.addressbook_address.country.to_record).to eql('_unitedStates')
        expect(list.addressbook_address.override).to be_falsey
        expect(list.addressbook_address.state).to eql('CA')
        expect(list.addressbook_address.zip).to eql('90007')
        expect(list.default_billing).to be_truthy
        expect(list.default_shipping).to be_truthy
        expect(list.is_residential).to be_falsey
        expect(list.label).to eql('123 Happy Lane')
        expect(list.internal_id).to eql('567')
      end
    end
  end

  describe '#to_record' do
    it 'can represent itself as a SOAP record' do
      record = {
          'listRel:addressbookAddress' => {
            'platformCommon:addr1'     => '123 Happy Lane',
            'platformCommon:city'      => 'Los Angeles',
            'platformCommon:country'   => '_unitedStates',
            'platformCommon:override'  => false,
            'platformCommon:state'     => 'CA',
            'platformCommon:zip'       => '90007'
          },
        'listRel:defaultBilling'  => true,
        'listRel:defaultShipping' => true,
        'listRel:isResidential'   => false,
        'listRel:label'           => '123 Happy Lane',
        'listRel:internalId'      => '567'
      }
      expect(list.to_record).to eql(record)
    end
  end

  describe '#record_type' do
    it 'returns a string of the record SOAP type' do
      expect(list.record_type).to eql('listRel:CustomerAddressbook')
    end
  end

  describe '#initialize_from_record (API < 2014_2)' do
    before { NetSuite::Configuration.api_version = '2014_1' }

    let(:legacy_attrs) do
      {
        default_shipping: true,
        default_billing:  false,
        is_residential:   true,
        label:            'Home',
        attention:        'Jane Smith',
        addressee:        'Smith Corp',
        phone:            '800-555-0100',
        addr1:            '10 Oak Ave',
        addr2:            'Apt 2',
        addr3:            '',
        city:             'Portland',
        zip:              '97201',
        override:         false,
        state:            'OR',
        internal_id:      '88'
      }
    end

    let(:source) { described_class.new(legacy_attrs) }
    let(:copy)   { described_class.new(source) }

    it 'copies scalar address fields from the source record' do
      expect(copy.addr1).to eq('10 Oak Ave')
      expect(copy.addr2).to eq('Apt 2')
      expect(copy.city).to eq('Portland')
      expect(copy.zip).to eq('97201')
      expect(copy.state).to eq('OR')
      expect(copy.phone).to eq('800-555-0100')
    end

    it 'copies identity/label fields' do
      expect(copy.attention).to eq('Jane Smith')
      expect(copy.addressee).to eq('Smith Corp')
      expect(copy.label).to eq('Home')
      expect(copy.internal_id).to eq('88')
    end

    it 'copies boolean flags' do
      expect(copy.default_shipping).to be true
      expect(copy.default_billing).to be false
      expect(copy.is_residential).to be true
      expect(copy.override).to be false
    end
  end

end
