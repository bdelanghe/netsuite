# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/checkAsyncStatus.html
module NetSuite
  module Actions
    class CheckAsyncStatus < AbstractAction
      include Support::Requests

      def initialize(job_id)
        @job_id = job_id
      end

      private

      # <soap:Body>
      #   <checkAsyncStatus>
      #     <jobId>WEBSERVICES_3392464_...</jobId>
      #   </checkAsyncStatus>
      # </soap:Body>
      def request_body
        { 'jobId' => @job_id }
      end

      def response_hash
        @response_hash ||= @response.body[:check_async_status_response][:async_status_result]
      end

      # Body exposes the full asyncStatusResult: job_id, status, percent_complete, est_remaining_duration
      def response_body
        @response_body ||= response_hash
      end

      # success? here means the SOAP call itself succeeded and we have a parseable result.
      # The async job status is exposed via response.body[:status].
      def success?
        @success ||= !response_hash.nil?
      end

      def action_name
        :check_async_status
      end
    end
  end
end
