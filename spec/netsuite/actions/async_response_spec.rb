require 'spec_helper'

# Unit tests for nil and edge-case response handling in the three async
# action classes, exercised without a Savon round-trip.
#
# Each action does a two-level hash access on the SOAP body:
#   body[:outer_key]&.fetch(:inner_key, nil)
#
# Nil at either level must not raise NoMethodError. These tests pin that
# contract and verify each action degrades gracefully rather than blowing
# up in production when NetSuite returns an unexpected response shape.

def build_action(klass, body_hash)
  action = klass.allocate
  action.instance_variable_set(:@response, double('response', body: body_hash))
  action
end

shared_examples 'nil-safe async response parsing' do |outer_key, inner_key|
  context 'when body is empty ({})' do
    subject(:action) { build_action(described_class, {}) }

    it 'response_hash returns nil without raising' do
      expect { action.send(:response_hash) }.not_to raise_error
      expect(action.send(:response_hash)).to be_nil
    end

    it 'response_body is nil' do
      expect(action.send(:response_body)).to be_nil
    end

    it 'success? returns false' do
      expect(action.send(:success?)).to be false
    end
  end

  context "when #{outer_key} is nil" do
    subject(:action) { build_action(described_class, { outer_key => nil }) }

    it 'response_hash returns nil without raising' do
      expect { action.send(:response_hash) }.not_to raise_error
      expect(action.send(:response_hash)).to be_nil
    end

    it 'success? returns false' do
      expect(action.send(:success?)).to be false
    end
  end

  context "when #{outer_key} is present but #{inner_key} is absent" do
    subject(:action) { build_action(described_class, { outer_key => {} }) }

    it 'response_hash returns nil' do
      expect(action.send(:response_hash)).to be_nil
    end

    it 'success? returns false' do
      expect(action.send(:success?)).to be false
    end
  end

  context "when #{inner_key} is explicitly nil" do
    subject(:action) { build_action(described_class, { outer_key => { inner_key => nil } }) }

    it 'response_hash returns nil' do
      expect(action.send(:response_hash)).to be_nil
    end

    it 'response_body is nil' do
      expect(action.send(:response_body)).to be_nil
    end
  end
end

describe NetSuite::Actions::AsyncAddList do
  include_examples 'nil-safe async response parsing',
    :async_add_list_response,
    :async_status_result

  context 'when status is an unrecognised value' do
    subject(:action) do
      build_action(described_class,
        async_add_list_response: { async_status_result: { status: 'unknown_status' } })
    end

    it 'success? returns false' do
      expect(action.send(:success?)).to be false
    end
  end

  context 'when status is "failed"' do
    subject(:action) do
      build_action(described_class,
        async_add_list_response: { async_status_result: { status: 'failed' } })
    end

    it 'success? returns false' do
      expect(action.send(:success?)).to be false
    end
  end
end

describe NetSuite::Actions::CheckAsyncStatus do
  include_examples 'nil-safe async response parsing',
    :check_async_status_response,
    :async_status_result
end

describe NetSuite::Actions::GetAsyncResult do
  include_examples 'nil-safe async response parsing',
    :get_async_result_response,
    :async_result

  context 'when async_result is present but status is absent' do
    subject(:action) do
      build_action(described_class,
        get_async_result_response: { async_result: {} })
    end

    it 'success? returns false without raising' do
      expect { action.send(:success?) }.not_to raise_error
      expect(action.send(:success?)).to be false
    end
  end

  context 'when status hash is present but @is_success is absent' do
    subject(:action) do
      build_action(described_class,
        get_async_result_response: { async_result: { status: {} } })
    end

    it 'success? returns false' do
      expect(action.send(:success?)).to be false
    end
  end

  context 'when @is_success is "false"' do
    subject(:action) do
      build_action(described_class,
        get_async_result_response: { async_result: { status: { :@is_success => 'false' } } })
    end

    it 'success? returns false' do
      expect(action.send(:success?)).to be false
    end
  end
end
