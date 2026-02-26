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
  # SOAP is deprecated — 2025.2 is the final endpoint (removed in 2028.2).
  # https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/section_3892701016.html
  WSDL_VERSION = 'v2025_2_0'.freeze

  BASE_URL      = 'https://webservices.netsuite.com'.freeze
  DOWNLOAD_BASE = 'https://content.netsuite.com/download'.freeze

  def zip_url(version)
    "#{DOWNLOAD_BASE}/WSDL_#{version}.zip"
  end

  desc 'Download WSDL fixtures for spec use (v2025_2_0 only). Set WSDL_SOURCE=<dir> to copy from local.'
  task :wsdl do
    require 'open-uri'
    require 'fileutils'
    require 'tmpdir'
    require 'uri'
    require 'zip'

    fixtures_root = File.join('spec', 'support', 'fixtures')
    soap_root     = File.join(fixtures_root, 'soap', WSDL_VERSION)
    local_source  = ENV['WSDL_SOURCE']

    if local_source
      install_from_dir(local_source, soap_root)
    else
      install_from_zip(zip_url(WSDL_VERSION), soap_root)
    end
  end

  # Install from the official NetSuite zip (https://content.netsuite.com/download/WSDL_<version>.zip).
  # The zip contains a flat directory of files with dotted naming: <category>.<file>.xsd
  def install_from_zip(url, soap_root)
    Dir.mktmpdir do |tmp|
      zip_path = File.join(tmp, 'wsdl.zip')
      puts "Downloading #{url}"
      URI.open(url) { |f| File.binwrite(zip_path, f.read) }

      puts "Extracting to #{soap_root}"
      Zip::File.open(zip_path) do |zip|
        zip.each do |entry|
          next if entry.directory?
          install_entry(entry.name, entry.get_input_stream.read, soap_root)
        end
      end
    end
  end

  # Copy from a pre-extracted local directory (flat dotted naming convention).
  def install_from_dir(source_dir, soap_root)
    Dir[File.join(source_dir, '*')].each do |src|
      install_entry(File.basename(src), File.binread(src), soap_root)
    end
  end

  # Route a single flat filename to its structured destination.
  # netsuite.wsdl             -> wsdl/netsuite.wsdl
  # platform.core.xsd         -> xsd/platform/core.xsd
  # transactions.sales.xsd    -> xsd/transactions/sales.xsd
  def install_entry(filename, content, soap_root)
    dest = if filename == 'netsuite.wsdl'
      File.join(soap_root, 'wsdl', 'netsuite.wsdl')
    else
      category, rest = filename.split('.', 2)
      File.join(soap_root, 'xsd', category, rest)
    end

    FileUtils.mkdir_p(File.dirname(dest))
    File.binwrite(dest, content)
    puts "  #{filename} -> #{dest}"
  end
end

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', '/gems/,spec']
end
