# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncUpdateList.html
module NetSuite
  module Actions
    class AsyncUpdateList < UpdateList
      include AsyncResponse

      private

      def async_response_key
        :async_update_list_response
      end

      def action_name
        :async_update_list
      end

      module Support
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def async_update_list(records, credentials = {})
            netsuite_records = records.map do |r|
              if r.kind_of?(self)
                r
              else
                self.new(r)
              end
            end

            response = NetSuite::Actions::AsyncUpdateList.call(netsuite_records, credentials)

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
