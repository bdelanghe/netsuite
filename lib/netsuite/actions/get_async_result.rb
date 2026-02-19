# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/getAsyncResult.html
module NetSuite
  module Actions
    class GetAsyncResult < AbstractAction
      include Support::Requests
      include AsyncResponse

      def initialize(job_id, page_index)
        @job_id = job_id
        @page_index = page_index
      end

      private

      def request_body
        {
          'platformMsgs:jobId'    => @job_id,
          'platformMsgs:pageIndex' => @page_index
        }
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
