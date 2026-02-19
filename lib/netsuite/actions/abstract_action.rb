module NetSuite
  module Actions
    class AbstractAction
      def request(credentials={})
        NetSuite::Client.call(action_name, message: request_body, request_options: request_options, credentials: credentials, soap_header_extra_info: soap_header_extra_info)
      end

      protected

      def action_name
        raise NotImplementedError, 'Not implemented on abstract class'
      end

      def initialize
        raise NotImplementedError, 'Not implemented on abstract class'
      end

      def request_body
        raise NotImplementedError, 'Not implemented on abstract class'
      end

      def request_options
        {}
      end

      def soap_header_extra_info
        {}
      end
    end
  end
end
  