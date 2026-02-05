# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncDeleteList.html
module NetSuite
  module Actions
    class AsyncDeleteList < DeleteList
      include AsyncResponse

      private

      def async_response_key
        :async_delete_list_response
      end

      def action_name
        :async_delete_list
      end

      module Support
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def async_delete_list(options = { }, credentials={})
            NetSuite::Actions::AsyncDeleteList.call([self, options], credentials)
          end
        end
      end
    end
  end
end
