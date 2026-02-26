# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/getAsyncResult.html
module NetSuite
  module Actions
    class GetAsyncResult < AbstractAction
      include Support::Requests

      def initialize(job_id, page_index = 1)
        @job_id     = job_id
        @page_index = page_index
      end

      private

      # <soap:Body>
      #   <getAsyncResult>
      #     <jobId>WEBSERVICES_3392464_...</jobId>
      #     <pageIndex>1</pageIndex>
      #   </getAsyncResult>
      # </soap:Body>
      def request_body
        { 'jobId' => @job_id, 'pageIndex' => @page_index }
      end

      def response_hash
        @response_hash ||= @response.body[:get_async_result_response][:async_result]
      end

      # Body is the full asyncResult: status, totalRecords, writeResponseList (or searchResult, etc.)
      def response_body
        @response_body ||= response_hash
      end

      def success?
        @success ||= response_hash[:status][:@is_success] == 'true'
      end

      def action_name
        :get_async_result
      end
    end
  end
end
