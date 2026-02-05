# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncAddList.html
module NetSuite
  module Actions
    class AsyncAddList < AbstractAction
      include Support::Requests
      include AsyncResponse

      def initialize(*objects)
        @objects = objects
      end

      private

      def request_body
        attrs = @objects.map do |o|
          hash = o.to_record.merge({
            '@xsi:type' => o.record_type
          })

          if o.respond_to?(:internal_id) && o.internal_id
            hash['@internalId'] = o.internal_id
          end

          if o.respond_to?(:external_id) && o.external_id
            hash['@externalId'] = o.external_id
          end

          hash
        end

        { 'record' => attrs }
      end

      def async_response_key
        :async_add_list_response
      end

      def action_name
        :async_add_list
      end

      module Support
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def async_add_list(records, credentials = {})
            netsuite_records = records.map do |r|
              if r.kind_of?(self)
                r
              else
                self.new(r)
              end
            end

            response = NetSuite::Actions::AsyncAddList.call(netsuite_records, credentials)

            if response.success?
              response.body
            else
              false
            end
          end
        end
      end
    end
  end
end
