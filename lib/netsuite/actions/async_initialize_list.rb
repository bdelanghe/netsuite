# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/asyncInitializeList.html
module NetSuite
  module Actions
    class AsyncInitializeList < AbstractAction
      include Support::Requests
      include AsyncResponse

      def initialize(*entries)
        @entries = entries
      end

      private

      def request_body
        initialize_records = @entries.map do |entry|
          klass, object = normalize_entry(entry)

          {
            'platformCore:type'      => NetSuite::Support::Records.netsuite_type(klass),
            'platformCore:reference' => {},
            :attributes!             => {
              'platformCore:reference' => {
                'internalId' => object.internal_id,
                :type        => NetSuite::Support::Records.netsuite_type(object)
              }
            }
          }
        end

        {
          'platformMsgs:initializeRecord' => initialize_records
        }
      end

      def normalize_entry(entry)
        case entry
        when Array
          entry
        when Hash
          klass = entry[:type] || entry[:klass] || entry[:record_type]
          object = entry[:reference] || entry[:object]
          [klass, object]
        else
          raise ArgumentError, "initialize list entries must be an Array or Hash"
        end
      end

      def async_response_key
        :async_initialize_list_response
      end

      def request_options
        {
          namespaces: {
            'xmlns:platformMsgs'    => "urn:messages_#{NetSuite::Configuration.api_version}.platform.webservices.netsuite.com",
            'xmlns:platformCore'    => "urn:core_#{NetSuite::Configuration.api_version}.platform.webservices.netsuite.com",
            'xmlns:platformCoreTyp' => "urn:types.core_#{NetSuite::Configuration.api_version}.platform.webservices.netsuite.com",
          }
        }
      end

      def action_name
        :async_initialize_list
      end

      module Support
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def async_initialize_list(records, credentials = {})
            response = NetSuite::Actions::AsyncInitializeList.call(records, credentials)

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
