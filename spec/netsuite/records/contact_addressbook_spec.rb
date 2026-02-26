require 'spec_helper'

describe NetSuite::Records::ContactAddressbook do
  let(:pre_2014_attrs) do
    {
      default_shipping: true,
      default_billing:  false,
      is_residential:   true,
      label:            'Home',
      attention:        'John Doe',
      addressee:        'Doe Corp',
      phone:            '555-1234',
      addr1:            '1 Main St',
      addr2:            'Suite 100',
      addr3:            '',
      city:             'Springfield',
      zip:              '12345',
      override:         false,
      state:            'CA',
      internal_id:      '42'
    }
  end

  let(:post_2014_attrs) do
    {
      addressbook: {
        addressbook_address: NetSuite::Records::Address.new(
          addr1:   '1 Main St',
          city:    'Springfield',
          state:   'CA',
          zip:     '12345',
          country: '_unitedStates',
          override: false
        ),
        default_billing:  true,
        default_shipping: false,
        internal_id:      '99',
        is_residential:   false,
        label:            'Office'
      }
    }
  end

  # ── initialize: Hash paths ────────────────────────────────────────────────

  describe '#initialize' do
    context 'with a flat attributes hash (no :addressbook wrapper)' do
      before { NetSuite::Configuration.api_version = '2014_2' }

      let(:record) { described_class.new(label: 'Shipping', internal_id: '7') }

      it 'sets label' do
        expect(record.label).to eq('Shipping')
      end

      it 'sets internal_id' do
        expect(record.internal_id).to eq('7')
      end
    end

    context 'with an :addressbook-wrapped hash (API >= 2014_2)' do
      before { NetSuite::Configuration.api_version = '2014_2' }

      let(:record) { described_class.new(post_2014_attrs) }

      it 'unwraps the :addressbook key and sets label' do
        expect(record.label).to eq('Office')
      end

      it 'sets internal_id' do
        expect(record.internal_id).to eq('99')
      end

      it 'sets default_billing' do
        expect(record.default_billing).to be true
      end

      it 'sets default_shipping' do
        expect(record.default_shipping).to be false
      end

      it 'sets is_residential' do
        expect(record.is_residential).to be false
      end

      it 'populates addressbook_address' do
        expect(record.addressbook_address).to be_a(NetSuite::Records::Address)
        expect(record.addressbook_address.addr1).to eq('1 Main St')
      end
    end
  end

  # ── initialize_from_record: API < 2014_2 branch ──────────────────────────

  describe '#initialize_from_record (API < 2014_2)' do
    before { NetSuite::Configuration.api_version = '2014_1' }

    let(:source) { described_class.new(pre_2014_attrs) }
    let(:copy)   { described_class.new(source) }

    it 'copies default_shipping' do
      expect(copy.default_shipping).to eq(source.default_shipping)
    end

    it 'copies default_billing' do
      expect(copy.default_billing).to eq(source.default_billing)
    end

    it 'copies is_residential' do
      expect(copy.is_residential).to eq(source.is_residential)
    end

    it 'copies label' do
      expect(copy.label).to eq(source.label)
    end

    it 'copies attention' do
      expect(copy.attention).to eq(source.attention)
    end

    it 'copies addressee' do
      expect(copy.addressee).to eq(source.addressee)
    end

    it 'copies phone' do
      expect(copy.phone).to eq(source.phone)
    end

    it 'copies addr1' do
      expect(copy.addr1).to eq(source.addr1)
    end

    it 'copies addr2' do
      expect(copy.addr2).to eq(source.addr2)
    end

    it 'copies city' do
      expect(copy.city).to eq(source.city)
    end

    it 'copies zip' do
      expect(copy.zip).to eq(source.zip)
    end

    it 'copies override' do
      expect(copy.override).to eq(source.override)
    end

    it 'copies state' do
      expect(copy.state).to eq(source.state)
    end

    it 'copies internal_id' do
      expect(copy.internal_id).to eq(source.internal_id)
    end
  end

  # ── initialize_from_record: API >= 2014_2 branch ─────────────────────────

  describe '#initialize_from_record (API >= 2014_2)' do
    before { NetSuite::Configuration.api_version = '2014_2' }

    let(:source) { described_class.new(post_2014_attrs) }
    let(:copy)   { described_class.new(source) }

    it 'copies addressbook_address' do
      expect(copy.addressbook_address.addr1).to eq('1 Main St')
    end

    it 'copies default_billing' do
      expect(copy.default_billing).to be true
    end

    it 'copies default_shipping' do
      expect(copy.default_shipping).to be false
    end

    it 'copies internal_id' do
      expect(copy.internal_id).to eq('99')
    end

    it 'copies is_residential' do
      expect(copy.is_residential).to be false
    end

    it 'copies label' do
      expect(copy.label).to eq('Office')
    end
  end
end
