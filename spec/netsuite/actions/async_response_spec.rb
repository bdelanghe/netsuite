require 'spec_helper'

describe NetSuite::Actions::AsyncResponse do
  # Test double that includes the mixin directly.
  # We set @response manually to simulate what Support::Requests sets after the HTTP call.
  let(:test_class) do
    Class.new do
      include NetSuite::Actions::AsyncResponse

      attr_writer :response

      # Expose private methods under test
      public :response_hash, :response_body, :success?, :errors
    end
  end

  subject(:action) do
    obj = test_class.new
    obj.response = double('savon_response', body: body)
    obj
  end

  describe '#response_hash' do
    context 'with nil body' do
      let(:body) { nil }

      it 'returns nil' do
        expect(action.response_hash).to be_nil
      end
    end

    context 'with empty Hash body' do
      let(:body) { {} }

      it 'falls back to the body itself' do
        expect(action.response_hash).to eq({})
      end
    end

    context 'with a non-Hash body' do
      let(:body) { 'error string' }

      it 'returns the body as-is' do
        expect(action.response_hash).to eq('error string')
      end
    end

    context 'when async_response_key is absent from body' do
      # Default async_response_key is nil, so the unwrap branch is skipped.
      let(:body) { { async_status_result: { job_id: 'JOB-1', status: 'pending' } } }

      it 'unwraps using async_result_key (:async_status_result)' do
        expect(action.response_hash).to eq({ job_id: 'JOB-1', status: 'pending' })
      end
    end

    context 'when body has no async_result_key' do
      let(:body) { { some_other_key: 'value' } }

      it 'returns the body unchanged' do
        expect(action.response_hash).to eq({ some_other_key: 'value' })
      end
    end

    context 'with a subclass that overrides async_response_key' do
      let(:subclass) do
        Class.new do
          include NetSuite::Actions::AsyncResponse

          attr_writer :response

          public :response_hash

          private

          def async_response_key
            :check_async_status_response
          end
        end
      end

      def build_subclass(body)
        obj = subclass.new
        obj.response = double('savon_response', body: body)
        obj
      end

      context 'when the key is present in body' do
        let(:inner) { { async_status_result: { job_id: 'JOB-2', status: 'finished' } } }
        subject(:action) { build_subclass({ check_async_status_response: inner }) }

        it 'unwraps via async_response_key then async_result_key' do
          expect(action.response_hash).to eq({ job_id: 'JOB-2', status: 'finished' })
        end
      end

      context 'when the key is missing from body' do
        subject(:action) { build_subclass({ other_key: 'data' }) }

        it 'skips unwrap and falls through to async_result_key lookup' do
          expect(action.response_hash).to eq({ other_key: 'data' })
        end
      end
    end
  end

  describe '#success?' do
    context 'with nil body' do
      let(:body) { nil }

      it 'returns false' do
        expect(action.success?).to be false
      end
    end

    context 'with empty Hash body' do
      let(:body) { {} }

      it 'returns true (no :@is_success key)' do
        expect(action.success?).to be true
      end
    end

    context 'with status @is_success = "true"' do
      let(:body) { { status: { :@is_success => 'true' } } }

      it 'returns true' do
        expect(action.success?).to be true
      end
    end

    context 'with status @is_success = "false"' do
      let(:body) { { status: { :@is_success => 'false' } } }

      it 'returns false' do
        expect(action.success?).to be false
      end
    end

    context 'with status as a non-Hash' do
      let(:body) { { status: 'not_a_hash' } }

      it 'returns true (status is not a Hash with :@is_success)' do
        expect(action.success?).to be true
      end
    end

    context 'with status Hash but no :@is_success key' do
      let(:body) { { status: { code: 'OK' } } }

      it 'returns true' do
        expect(action.success?).to be true
      end
    end
  end

  describe '#errors' do
    context 'when status_detail is a Hash (single error)' do
      let(:error_detail) { { code: 'USER_ERROR', message: 'Something went wrong', after_submit_failed: false } }
      let(:body) { { status: { :@is_success => 'false', status_detail: error_detail } } }

      it 'wraps the Hash in an Array and returns one NetSuite::Error' do
        result = action.errors
        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result.first).to be_kind_of(NetSuite::Error)
      end
    end

    context 'when status_detail is an Array (multiple errors)' do
      let(:error_details) do
        [
          { code: 'USER_ERROR', message: 'First error' },
          { code: 'SYS_ERROR', message: 'Second error' }
        ]
      end
      let(:body) { { status: { :@is_success => 'false', status_detail: error_details } } }

      it 'maps each element to a NetSuite::Error' do
        result = action.errors
        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result).to all(be_kind_of(NetSuite::Error))
      end
    end
  end
end
