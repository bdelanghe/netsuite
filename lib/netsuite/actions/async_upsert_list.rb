# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncUpsertList.html
module NetSuite
  module Actions
    class AsyncUpsertList < UpsertList
      include AsyncResponse

      private

      MAX_RECORDS = 200

      def initialize(*objects)
        if objects.size > MAX_RECORDS
          raise ArgumentError, "asyncUpsertList supports a maximum of #{MAX_RECORDS} records per request (#{objects.size} given)"
        end
        super
      end

      def async_response_key
        :async_upsert_list_response
      end

      def action_name
        :async_upsert_list
      end

      module Support
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def async_upsert_list(records, credentials = {})
            netsuite_records = records.map do |r|
              if r.kind_of?(self)
                r
              else
                self.new(r)
              end
            end

            response = NetSuite::Actions::AsyncUpsertList.call(netsuite_records, credentials)

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
