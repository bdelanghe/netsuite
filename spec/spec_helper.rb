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

# https://circleci.com/docs/code-coverage
if ENV['CIRCLE_ARTIFACTS']
  require 'simplecov'
  dir = File.join("../../../..", ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
  SimpleCov.start
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir['spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.color = true

  # Keep integration tests opt-in to avoid live NetSuite calls by default.
  config.filter_run_excluding integration: true unless ENV['NETSUITE_INTEGRATION'] == 'true'
end
