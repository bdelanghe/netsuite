module NetSuite
  module Actions
    module AsyncResponse
      private

      def response_hash
        @response_hash ||= begin
          body = @response.body
          if body.is_a?(Hash) && async_response_key && body[async_response_key]
            body = body[async_response_key]
          end
          body.is_a?(Hash) ? (body[async_result_key] || body) : body
        end
      end

      def response_body
        @response_body ||= response_hash
      end

      def response_errors
        if response_hash.is_a?(Hash) && response_hash[:status].is_a?(Hash) && response_hash[:status][:status_detail]
          @response_errors ||= errors
        end
      end

      def errors
        error_obj = response_hash[:status][:status_detail]
        error_obj = [error_obj] if error_obj.class == Hash
        error_obj.map do |error|
          NetSuite::Error.new(error)
        end
      end

      def success?
        return false unless response_hash.is_a?(Hash)

        status = response_hash[:status]
        return true unless status.is_a?(Hash) && status.key?(:@is_success)

        status[:@is_success] == 'true'
      end

      def async_response_key
        nil
      end

      def async_result_key
        :async_status_result
      end
    end
  end
end
