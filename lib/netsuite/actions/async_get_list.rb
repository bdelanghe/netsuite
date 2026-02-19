# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncGetList.html
module NetSuite
  module Actions
    class AsyncGetList < GetList
      include AsyncResponse

      private

      MAX_RECORDS = 2000

      def initialize(klass, options = {})
        list = options.is_a?(Hash) ? (options[:list] || []) : Array(options)
        if list.size > MAX_RECORDS
          raise ArgumentError, "asyncGetList supports a maximum of #{MAX_RECORDS} records per request (#{list.size} given)"
        end
        super
      end

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
