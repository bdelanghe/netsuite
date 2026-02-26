# -*- encoding: utf-8 -*-
require File.expand_path('../lib/netsuite/version', __FILE__)

Gem::Specification.new do |gem|
  gem.licenses      = ['MIT']
  gem.authors       = ['Robert DeLanghe']
  gem.email         = ['dev@robertdelanghe.com']
  gem.description   = %q{Ruby wrapper for the NetSuite SuiteTalk SOAP Web Services API (v2025.2). Targets the final supported SOAP endpoint (scheduled for removal in 2028.2 per Oracle's deprecation timeline). Includes async bulk operations (asyncAddList, asyncUpdateList, asyncUpsertList, asyncDeleteList, asyncGetList).}
  gem.summary       = %q{NetSuite SuiteTalk SOAP v2025.2 wrapper with async list operations}
  gem.homepage      = 'https://github.com/bdelanghe/netsuite'

  gem.post_install_message = <<~MSG
    Thank you for installing netsuite-soap.

    NOTE: NetSuite is deprecating SOAP Web Services.
      - 2025.2 is the final supported SOAP endpoint.
      - SOAP is scheduled for removal in NetSuite 2028.2.

    New integrations should use SuiteTalk REST Web Services with OAuth 2.0.
    https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/chapter_1540391670.html
  MSG

  # Use git ls-files when available (development); fall back to Dir.glob for
  # builds from source archives or environments without git.
  git_files = `git ls-files -z 2>/dev/null`.split("\x0")
  gem.files         = git_files.any? ? git_files : Dir.glob('{bin,lib}/**/*') + %w[README.md LICENSE HISTORY.md netsuite.gemspec]
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }

  gem.name          = 'netsuite-soap'
  gem.require_paths = ['lib']
  gem.version       = NetSuite::VERSION

  # 3.4+ required: relies on `it` block parameter syntax and PRISM-based parse
  # behaviour introduced in 3.4. Intentional; do not lower without testing.
  gem.required_ruby_version = '~> 3.4'

  gem.metadata['changelog_uri']     = 'https://github.com/bdelanghe/netsuite/blob/main/HISTORY.md'
  gem.metadata['bug_tracker_uri']   = 'https://github.com/bdelanghe/netsuite/issues'
  gem.metadata['source_code_uri']   = 'https://github.com/bdelanghe/netsuite'
  gem.metadata['documentation_uri'] = 'https://github.com/bdelanghe/netsuite#readme'
  gem.metadata['homepage_uri']      = 'https://github.com/bdelanghe/netsuite'
  gem.metadata['rubygems_mfa_required'] = 'true'

  # != 2.13.0: that release had regressions in SOAP header/namespace handling.
  # < 3: Savon 3.x is a rewrite with breaking API changes; pin to 2.x until
  # we validate compatibility.
  gem.add_dependency 'savon', '>= 2.3.0', '!= 2.13.0', '< 3'
  gem.add_dependency 'rack', '< 4'
  gem.add_dependency 'tzinfo', '~> 2.0'

  gem.add_development_dependency 'rspec', '~> 3.13.0'
  gem.add_development_dependency 'webmock', '~> 3.19'
end
