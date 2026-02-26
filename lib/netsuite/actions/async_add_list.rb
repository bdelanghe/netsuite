# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncAddList.html
module NetSuite
  module Actions
    class AsyncAddList < AbstractAction
      include Support::Requests

      def initialize(*objects)
        @objects = objects
      end

      private

      # <soap:Body>
      #   <asyncAddList>
      #     <record xsi:type="listRel:Customer" externalId="ext1">
      #       <listRel:entityId>Shutter Fly</listRel:entityId>
      #       <listRel:companyName>Shutter Fly, Inc</listRel:companyName>
      #     </record>
      #   </asyncAddList>
      # </soap:Body>
      def request_body
        attrs = @objects.map do |o|
          hash = o.to_record.merge({ '@xsi:type' => o.record_type })
          hash['@externalId'] = o.external_id if o.respond_to?(:external_id) && o.external_id
          hash
        end
        { 'record' => attrs }
      end

      def response_hash
        @response_hash ||= @response.body[:async_add_list_response]&.fetch(:async_status_result, nil)
      end

      def response_body
        @response_body ||= response_hash
      end

      # The submit itself succeeds when NetSuite accepts the job (status is pending or processing).
      # A status of 'failed' means the submission was rejected.
      def success?
        @success ||= %w[pending processing finishedWithErrors complete].include?(response_hash&.fetch(:status, nil))
      end

      def request_options
        { element_form_default: :unqualified }
      end

      def action_name
        :async_add_list
      end
    end
  end
end
