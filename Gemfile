source 'https://rubygems.org'
gemspec

ruby '>= 3.1.0'

gem 'rubyzip'

# rack < 3 is intentional: httpi (savon's HTTP layer) is not yet Rack 3 compatible.
# Track: https://github.com/bdelanghe/netsuite/issues/2
gem 'rack', '< 4'

gem 'mail', '~> 2.9'
gem 'tzinfo', '>= 1.2.5'

group :development, :test do
  gem 'simplecov', require: false
  gem 'pry-nav'
  gem 'pry-rescue'
end
