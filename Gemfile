source 'https://rubygems.org'

ruby '1.9.3'
gem 'rails', '~> 3.2.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'


# Gems used only for assets and not required
# in production environments by default.
#group :assets do
  gem 'sass', '~> 3.1.0'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'compass-rails'
  gem 'sassy-buttons'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'modernizr-rails'


  gem 'uglifier', '>= 1.0.3'
#end

group :development, :test do
  gem "rspec-rails", '~> 2.14.0'
  gem "factory_girl_rails"
  gem "spork-rails"

  # Use thin web-server in dev
  gem 'thin'
end

group :development do
  gem "quiet_assets"
  gem "better_errors", '~> 1.1.0'
  gem "binding_of_caller"
  gem "erb2haml"
end

group :test do
  gem 'debugger'
  gem "database_cleaner"
  gem "email_spec"
  gem "launchy"
  gem "capybara", '~> 2.3.0'
  gem 'selenium-webdriver'
  gem 'coveralls', require: false
  gem 'timecop'
  gem 'shoulda-matchers'

  # Let Travis see Rake
  gem 'rake'
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

# Squeel - simpler SQL queries through AREL
gem 'squeel'

# Ransack - complex search forms
gem 'ransack'

# Delayed job and manager for its workers
gem "delayed_job_active_record"
gem "workless", "~> 1.1.3", :group => :production

# To display phone numbers correctly
gem 'uk_phone_numbers'

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
