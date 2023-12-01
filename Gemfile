source 'https://rubygems.org'

ruby '3.2.2'

gem 'bootsnap', require: false
gem 'importmap-rails'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.2'
gem 'redis', '>= 4.0.1'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[ windows jruby ]

group :development, :test do
  gem 'brakeman'
  gem 'debug', platforms: %i[ mri windows ]
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'rspec-rails', '6.1.0'
  gem 'selenium-webdriver'
end
