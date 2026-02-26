require 'spec_helper'

describe NetSuite::Records::ContactList do
  describe '#initialize' do
    context 'with empty attributes' do
      subject(:list) { described_class.new({}) }

      it 'starts with an empty contacts array' do
        expect(list.contacts).to eq([])
      end
    end

    context 'when :contact is a Hash (single contact)' do
      subject(:list) { described_class.new(contact: { internal_id: '1', entity_id: 'Alice' }) }

      it 'adds one Contact to the contacts array' do
        expect(list.contacts.length).to eq(1)
      end

      it 'wraps the hash in a Contact' do
        expect(list.contacts.first).to be_a(NetSuite::Records::Contact)
      end
    end

    context 'when :contact is an Array (multiple contacts)' do
      subject(:list) do
        described_class.new(contact: [
          { internal_id: '1', entity_id: 'Alice' },
          { internal_id: '2', entity_id: 'Bob' }
        ])
      end

      it 'adds all contacts to the contacts array' do
        expect(list.contacts.length).to eq(2)
      end

      it 'wraps each hash in a Contact' do
        list.contacts.each { |c| expect(c).to be_a(NetSuite::Records::Contact) }
      end
    end
  end

  describe '#<<' do
    subject(:list) { described_class.new({}) }

    it 'appends a contact to the contacts array' do
      contact = NetSuite::Records::Contact.new(entity_id: 'Charlie')
      list << contact
      expect(list.contacts).to include(contact)
    end
  end

  describe '#contacts' do
    subject(:list) { described_class.new({}) }

    it 'returns an Array' do
      expect(list.contacts).to be_an(Array)
    end

    it 'is memoized' do
      expect(list.contacts).to equal(list.contacts)
    end
  end

  describe '#to_record' do
    subject(:list) do
      described_class.new(contact: { internal_id: '1', entity_id: 'Alice' })
    end

    it 'returns a Hash' do
      expect(list.to_record).to be_a(Hash)
    end

    it 'contains the actSched:contact key' do
      expect(list.to_record).to have_key('actSched:contact')
    end

    it 'serialises each contact via to_record' do
      expect(list.to_record['actSched:contact']).to be_an(Array)
    end
  end
end
