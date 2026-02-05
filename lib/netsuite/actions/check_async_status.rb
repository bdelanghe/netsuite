# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/checkAsyncStatus.html
module NetSuite
  module Actions
    class CheckAsyncStatus < AbstractAction
      include Support::Requests
      include AsyncResponse

      def initialize(job_id)
        @job_id = job_id
      end

      private

      def request_body
        {
          'platformMsgs:jobId' => @job_id
        }
      end

      def async_response_key
        :check_async_status_response
      end

      def action_name
        :check_async_status
      end
    end
  end
end
