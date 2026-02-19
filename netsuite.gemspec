# -*- encoding: utf-8 -*-
require File.expand_path('../lib/netsuite/version', __FILE__)

Gem::Specification.new do |gem|
  gem.licenses      = ['MIT']
  gem.authors       = ['Robert DeLanghe']
  gem.email         = ['dev@robertdelanghe.com']
  gem.description   = %q{Ruby wrapper for the NetSuite SuiteTalk SOAP Web Services API (v2025.2). Targets the final supported SOAP endpoint (removed 2028.2). Includes async bulk operations (asyncAddList, asyncUpdateList, asyncUpsertList, asyncDeleteList, asyncGetList).}
  gem.summary       = %q{NetSuite SuiteTalk SOAP v2025.2 wrapper with async list operations}
  gem.homepage      = 'https://github.com/bdelanghe/netsuite'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'netsuite'
  gem.require_paths = ['lib']
  gem.version       = NetSuite::VERSION
  gem.required_ruby_version = '>= 3.1'
  gem.metadata['changelog_uri'] = 'https://github.com/bdelanghe/netsuite/blob/main/HISTORY.md'
  gem.metadata['mailing_list_uri'] = 'https://github.com/bdelanghe/netsuite/issues'
  gem.metadata['rubygems_mfa_required'] = 'true'
  gem.metadata['github_repo'] = 'https://github.com/bdelanghe/netsuite'

  gem.add_dependency 'savon', '>= 2.3.0', '!= 2.13.0'
  gem.add_dependency 'rack', '< 4'
  gem.add_dependency 'tzinfo', '~> 2.0'

  gem.add_development_dependency 'rspec', '~> 3.13.0'
  gem.add_development_dependency 'webmock', '~> 3.19'
end
