require 'spec_helper'

describe NetSuite::Support::Requests do
  # Minimal class that implements the interface so partial-double stubs are valid.
  let(:requestable_class) do
    Class.new do
      include NetSuite::Support::Requests
      def request(*) end
      def success?; true; end
      def response_body; {}; end
    end
  end
  let(:instance) { requestable_class.new }

  describe '#call' do
    before do
      allow(instance).to receive(:request)
      allow(instance).to receive(:success?)
      allow(instance).to receive(:response_body)
    end

    it 'calls #request' do
      expect(instance).to receive(:request)
      instance.call
    end

    it 'calls #build_response' do
      expect(instance).to receive(:build_response)
      instance.call
    end

    it 'returns a NetSuite::Response object' do
      response = instance.call
      expect(response).to be_kind_of(NetSuite::Response)
    end
  end

end
