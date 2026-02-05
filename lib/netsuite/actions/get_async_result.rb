# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/getAsyncResult.html
module NetSuite
  module Actions
    class GetAsyncResult < AbstractAction
      include Support::Requests
      include AsyncResponse

      def initialize(job_id, options = {})
        @job_id = job_id
        @options = options
      end

      private

      def request_body
        body = {
          'platformMsgs:jobId' => @job_id
        }

        page_index = @options[:page_index] || @options[:pageIndex]
        body['platformMsgs:pageIndex'] = page_index if page_index

        body
      end

      def async_response_key
        :get_async_result_response
      end

      def async_result_key
        :async_result
      end

      def action_name
        :get_async_result
      end
    end
  end
end
