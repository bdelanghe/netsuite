# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncDeleteList.html
module NetSuite
  module Actions
    class AsyncDeleteList < DeleteList
      include AsyncResponse

      private

      MAX_RECORDS = 400

      def initialize(klass, options = {})
        list = options.is_a?(Hash) ? (options[:list] || []) : Array(options)
        if list.size > MAX_RECORDS
          raise ArgumentError, "asyncDeleteList supports a maximum of #{MAX_RECORDS} records per request (#{list.size} given)"
        end
        super
      end

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
