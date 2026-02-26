# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncSearch.html
module NetSuite
  module Actions
    class AsyncSearch < Search
      include AsyncResponse

      private

      def async_response_key
        :async_search_response
      end

      def action_name
        :async_search
      end

      module Support
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def async_search(options = { }, credentials={})
            response = NetSuite::Actions::AsyncSearch.call([self, options], credentials)

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
