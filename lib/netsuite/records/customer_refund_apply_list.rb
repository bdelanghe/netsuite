module NetSuite
  module Records
    class CustomerRefundApplyList < Support::Sublist
      include Namespaces::TranCust

      sublist :apply, CustomerRefundApply

      alias :applies :apply

    end
  end
end
