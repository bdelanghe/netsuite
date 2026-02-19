# Single boundary for all SOAP calls. All Savon usage is behind this interface.
# Today: delegates to Configuration.connection (Savon). Later: Faraday (transport) +
# Nokogiri (build envelope, parse response) — keep transport and structure on separate layers.
module NetSuite
  class Client
    class << self
      # @param operation [Symbol] SOAP operation name (e.g. :get, :search, :get_server_time)
      # @param message [Hash] request body (namespaced keys, e.g. "platformMsgs:record")
      # @param request_options [Hash] passed to Configuration.connection (e.g. wsdl, namespaces, soap_header)
      # @param credentials [Hash] account, email, password, etc.
      # @param soap_header_extra_info [Hash] merged into SOAP header
      # @return [Object] response with #success? and #body (same shape as Savon today)
      def call(operation, message:, request_options: {}, credentials: {}, soap_header_extra_info: {})
        connection = Configuration.connection(request_options, credentials, soap_header_extra_info)
        connection.call(operation, message: message)
      end
    end
  end
end
