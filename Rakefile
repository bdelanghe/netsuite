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
  # Sources:
  #   https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/section_3892701016.html
  #   https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/section_N3413913.html
  # SOAP is deprecated — 2025.2 is the last planned endpoint (removed in 2028.2).
  WSDL_VERSIONS = {
    # Final endpoint — all integrations should target this
    'v2025_2_0' => { status: :final },
    # Supported
    'v2025_1_0' => { status: :supported },
    'v2024_2_0' => { status: :supported },
    'v2024_1_0' => { status: :supported },
    'v2023_2_0' => { status: :supported },
    'v2023_1_0' => { status: :supported },
    'v2022_2_0' => { status: :supported },
    # Unsupported but still available
    'v2022_1_0' => { status: :unsupported },
    'v2021_2_0' => { status: :unsupported },
    'v2021_1_0' => { status: :unsupported },
    'v2020_2_0' => { status: :unsupported },
    'v2020_1_0' => { status: :unsupported },
    'v2019_2_0' => { status: :unsupported },
    'v2019_1_0' => { status: :unsupported },
    'v2018_2_0' => { status: :unsupported }
  }.freeze

  BASE_URL      = 'https://webservices.netsuite.com'.freeze
  DOWNLOAD_BASE = 'https://content.netsuite.com/download'.freeze

  def wsdl_url(version)
    "#{BASE_URL}/wsdl/#{version}/netsuite.wsdl"
  end

  def zip_url(version)
    "#{DOWNLOAD_BASE}/WSDL_#{version}.zip"
  end

  desc 'Download WSDL fixtures and all referenced XSD schemas for spec use. ' \
       'Set VERSION=v2025_2_0 to fetch a single version. ' \
       'Set WSDL_SOURCE=<dir> to copy from a local directory instead of downloading.'
  task :wsdl do
    require 'open-uri'
    require 'fileutils'
    require 'rexml/document'
    require 'tmpdir'
    require 'uri'
    require 'zip'

    fixtures_root = File.join('spec', 'support', 'fixtures')
    local_source  = ENV['WSDL_SOURCE']

    versions = if ENV['VERSION']
      WSDL_VERSIONS.slice(ENV['VERSION']).tap do |v|
        abort "Unknown VERSION '#{ENV['VERSION']}'. Available: #{WSDL_VERSIONS.keys.join(', ')}" if v.empty?
      end
    else
      WSDL_VERSIONS
    end

    versions.each_key do |version|
      soap_root = File.join(fixtures_root, 'soap', version)

      if local_source
        install_from_dir(local_source, soap_root)
      else
        install_from_zip(zip_url(version), soap_root)
      end
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
