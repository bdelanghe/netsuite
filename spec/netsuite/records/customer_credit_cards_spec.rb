require 'spec_helper'

describe NetSuite::Records::CustomerCreditCards do
  let(:attrs) do
    {
      cc_default:       true,
      cc_expire_date:   '2028-12-01',
      cc_memo:          'Primary card',
      cc_name:          'Jane Doe',
      cc_number:        '4111',
      debitcard_issue_no: '2',
      state_from:       'CA',
      validfrom:        '2020-01-01'
    }
  end

  describe '#initialize' do
    context 'with a Hash of attributes' do
      subject(:card) { described_class.new(attrs) }

      it 'sets cc_default' do
        expect(card.cc_default).to be true
      end

      it 'sets cc_expire_date' do
        expect(card.cc_expire_date).to eq('2028-12-01')
      end

      it 'sets cc_memo' do
        expect(card.cc_memo).to eq('Primary card')
      end

      it 'sets cc_name' do
        expect(card.cc_name).to eq('Jane Doe')
      end

      it 'sets cc_number' do
        expect(card.cc_number).to eq('4111')
      end

      it 'sets debitcard_issue_no' do
        expect(card.debitcard_issue_no).to eq('2')
      end

      it 'sets state_from' do
        expect(card.state_from).to eq('CA')
      end

      it 'sets validfrom' do
        expect(card.validfrom).to eq('2020-01-01')
      end
    end

    context 'with a CustomerCreditCards instance (copy constructor)' do
      let(:source) { described_class.new(attrs) }
      subject(:copy) { described_class.new(source) }

      it 'copies cc_default' do
        expect(copy.cc_default).to eq(source.cc_default)
      end

      it 'copies cc_expire_date' do
        expect(copy.cc_expire_date).to eq(source.cc_expire_date)
      end

      it 'copies cc_memo' do
        expect(copy.cc_memo).to eq(source.cc_memo)
      end

      it 'copies cc_name' do
        expect(copy.cc_name).to eq(source.cc_name)
      end

      it 'copies cc_number' do
        expect(copy.cc_number).to eq(source.cc_number)
      end

      it 'copies debitcard_issue_no' do
        expect(copy.debitcard_issue_no).to eq(source.debitcard_issue_no)
      end

      it 'copies state_from' do
        expect(copy.state_from).to eq(source.state_from)
      end

      it 'copies validfrom' do
        expect(copy.validfrom).to eq(source.validfrom)
      end
    end
  end

  describe '#to_record' do
    subject(:card) { described_class.new(attrs) }

    it 'serialises cc_name into the SOAP record' do
      expect(card.to_record).to have_key('platformCore:ccName')
    end

    it 'serialises cc_number into the SOAP record' do
      expect(card.to_record).to have_key('platformCore:ccNumber')
    end
  end
end
