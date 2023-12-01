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
  gem 'debug', platforms: %i[ mri windows ]

  gem 'brakeman'
end

group :development do
  gem 'web-console'

  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'rspec-rails', '6.1.0'
  gem 'capybara'
  gem 'selenium-webdriver'
end
