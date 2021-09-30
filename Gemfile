source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'rails', '~> 6.1.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.3'
gem 'sass-rails', '>= 6'
gem 'webpacker'
gem 'turbolinks', '~> 5'
gem 'redis', '~> 4.0'
gem 'bcrypt', '~> 3.1.7'
gem 'httparty'
gem 'font_awesome5_rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # NOTE: turn off `parallelize()` in /test/test_helper.rb first!
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'minitest-rails'
  gem 'database_cleaner'
end

group :production do
  # Monitor with New Relic in production
  gem 'newrelic_rpm'
end
