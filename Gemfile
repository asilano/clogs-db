source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '~> 4.1.0'

gem 'rack-cache'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Peg pg to version supported by Ruby 1.9.3
gem 'pg', '~> 0.18.0'

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
  gem 'sass'
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'sassy-buttons'
  gem 'coffee-rails'
  gem 'modernizr-rails'


  gem 'uglifier', '>= 1.0.3'
#end

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "spork-rails"
  gem 'coffee-script-source', '1.8.0'

  # Use thin web-server in dev
  gem 'thin'

  gem 'byebug'
end

group :development do
  gem "quiet_assets"
  gem "better_errors", '~> 1.1.0'
  gem "binding_of_caller"
  #gem "erb2haml"
end

group :test do
  gem "database_cleaner"
  gem "email_spec"
  gem "launchy"
  gem "capybara"

  gem 'selenium-webdriver'
  gem 'capybara-selenium'
  gem 'chromedriver-helper'
  gem 'transactional_capybara'
  gem 'coveralls', require: false
  gem 'timecop'
  gem 'shoulda-matchers'

  # Let Travis see Rake
  # gem 'rake'

  # Peg to a version that supports Ruby 1.9.3
  gem 'nokogiri', '~> 1.6.0'
  gem 'tins', '1.3.3'
  gem 'term-ansicolor', '~> 1.3.0'
end

group :production do
  gem 'rails_12factor'

  # Use unicorn as the web server
  gem 'unicorn'
end

gem 'jquery-rails'
# Peg to version that supports Ruby 1.9.3
gem 'haml', '~> 4.0.0'
gem 'haml-rails'

gem 'attribute_normalizer'
gem 'andand'

# github.com/laserlemon/figaro - provide config in .gitignored application.yml
# accessible through ENV (like Heroku does)
gem 'figaro'

# User authentication by devise
# Peg version to work with ruby 2.0
gem 'devise', "3.5.10"

# Squeel - simpler SQL queries through AREL
gem 'squeel'

# Ransack - complex search forms
# Peg to a version supported by Ruby 1.9.3
gem 'ransack', '1.6.3'

# Delayed job and manager for its workers
gem "delayed_job_active_record"
gem "workless", "~> 1.1.3", :group => :production

# To display phone numbers correctly
gem 'uk_phone_numbers'

# To provide friendly URLs
gem 'friendly_id'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
