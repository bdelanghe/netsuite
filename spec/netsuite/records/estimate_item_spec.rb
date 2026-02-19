require 'spec_helper'

describe NetSuite::Records::EstimateItem do
  let(:item) { NetSuite::Records::EstimateItem.new }

  it 'has all the right fields' do
    [
     :amount, :cost_estimate, :cost_estimate_type,
     :defer_rev_rec, :description, 
     :is_taxable, :line, :quantity,
     :rate, :tax_rate1
    ].each do |field|
      expect(item).to have_field(field)
    end
  end

  it 'has all the right record refs' do
    [
      :department,
      :item,
      :job,
      :klass,
      :location,
      :price,
      :tax_code,
      :units,
    ].each do |record_ref|
      expect(item).to have_record_ref(record_ref)
    end
  end




end
