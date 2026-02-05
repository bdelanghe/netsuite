# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncGetList.html
module NetSuite
  module Actions
    class AsyncGetList < GetList
      include AsyncResponse

      private

      def async_response_key
        :async_get_list_response
      end

      def action_name
        :async_get_list
      end

      module Support
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def async_get_list(options = { }, credentials={})
            response = NetSuite::Actions::AsyncGetList.call([self, options], credentials)

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
