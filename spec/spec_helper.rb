$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..') ))

require "rubygems"
require "bundler/setup"

# Silence duplicate-constant warnings caused by net-protocol being both stdlib
# and a gem dependency under Ruby < 3.1.
if RUBY_VERSION < "3.1.0" && Warning.respond_to?(:warn)
  Warning.singleton_class.class_eval do
    unless method_defined?(:_netsuite_warn)
      alias_method :_netsuite_warn, :warn

      def warn(message)
        if message.include?("net/protocol.rb") &&
           (message.include?("already initialized constant Net::") ||
            message.include?("previous definition of"))
          return
        end

        _netsuite_warn(message)
      end
    end
  end
end

Bundler.require

# Rack 3.0 removed Rack::Utils::HeaderHash in favour of Rack::Headers.
# httpi ~> 3.0 still references the old constant, so shim it back in.
if defined?(Rack) && !defined?(Rack::Utils::HeaderHash)
  require 'rack'
  Rack::Utils::HeaderHash = Rack::Headers
end

if ENV['CI'] || ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir['spec/support/**/*.rb'].each { |f| require f }

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.mock_with :rspec do |m|
    m.verify_partial_doubles = true
  end
  config.color = true
  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run_when_matching :focus
end
