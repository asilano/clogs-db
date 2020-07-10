source 'https://rubygems.org'

ruby '~> 2.6.5'
gem 'rails', '~> 5.2.0'
gem 'railties'

gem 'rack-cache'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'bootsnap'

gem 'sass'
gem 'sass-rails'
gem 'compass-rails', '~> 3.1.0'
gem 'sassy-buttons'
gem 'coffee-rails'
gem 'modernizr-rails'

gem 'uglifier'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'coffee-script-source'

  # Use puma web-server in dev
  gem 'puma'
  gem 'listen'

  gem 'byebug'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'

  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'webdrivers'
  gem 'coveralls', require: false
  gem 'timecop'
  gem 'shoulda-matchers'
  gem 'rails-controller-testing'

  # Let Travis see Rake
  # gem 'rake'

  gem 'nokogiri'
  gem 'tins'
  gem 'term-ansicolor'
end

group :production do
  gem 'rails_12factor'

  # Use unicorn as the web server
  gem 'unicorn'
end

gem 'jquery-rails'
gem 'haml'
gem 'haml-rails'

gem 'attribute_normalizer'
gem 'andand'

# github.com/laserlemon/figaro - provide config in .gitignored application.yml
# accessible through ENV (like Heroku does)
gem 'figaro'

# User authentication by devise
gem 'devise'

# Ransack - complex search forms
gem 'ransack', github: 'activerecord-hackery/ransack'

# Delayed job and manager for its workers
gem 'delayed_job_active_record'
gem 'workless', group: :production

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
