#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  # t.pattern = './spec/**/*_spec.rb'
end

namespace :fixtures do
  WSDL_VERSIONS = {
    'v2021_1_0' => 'https://webservices.netsuite.com/wsdl/v2021_1_0/netsuite.wsdl'
  }.freeze

  desc 'Download WSDL fixtures and all referenced XSD schemas for spec use'
  task :wsdl do
    require 'open-uri'
    require 'fileutils'
    require 'rexml/document'
    require 'uri'

    fixtures_root = File.join('spec', 'support', 'fixtures')

    WSDL_VERSIONS.each do |version, wsdl_url|
      soap_root = File.join(fixtures_root, 'soap', version)
      wsdl_dest = File.join(soap_root, 'wsdl', 'netsuite.wsdl')
      FileUtils.mkdir_p(File.dirname(wsdl_dest))

      puts "Downloading #{wsdl_url} -> #{wsdl_dest}"
      wsdl_content = URI.open(wsdl_url, &:read)
      File.write(wsdl_dest, wsdl_content)
      puts "Saved #{wsdl_dest}"

      # Parse schemaLocation attributes from <xsd:import> elements
      doc = REXML::Document.new(wsdl_content)
      base_uri = URI.parse(wsdl_url)

      REXML::XPath.match(doc, '//*[@schemaLocation]').each do |node|
        schema_location = node.attributes['schemaLocation']
        next unless schema_location

        xsd_url = base_uri.merge(schema_location).to_s

        # Server path: /xsd/<category>/<version>/<file>
        # Local path:  soap/<version>/xsd/<category>/<file>
        _, _xsd, category, _ver, file = URI.parse(xsd_url).path.split('/')
        xsd_dest = File.join(soap_root, 'xsd', category, file)
        FileUtils.mkdir_p(File.dirname(xsd_dest))

        puts "Downloading #{xsd_url} -> #{xsd_dest}"
        URI.open(xsd_url) { |f| File.write(xsd_dest, f.read) }
        puts "Saved #{xsd_dest}"
      end
    end
  end
end

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', '/gems/,spec']
end
