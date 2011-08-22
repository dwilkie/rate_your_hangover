source 'http://rubygems.org'

gem 'rails', '3.1.0.rc4'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

# Asset template engines
gem 'sass'
gem 'coffee-script'
gem 'uglifier'

gem 'jquery-rails'

gem 'carrierwave'
gem 'carrierwave_direct', :path => "/home/dave/work/plugins/carrierwave_direct"
gem "rmagick"
gem 'fog'
gem 'haml-rails'
gem 'simple_form'
gem 'devise', '1.4.0'
gem 'squeel', :git => "git://github.com/ernie/squeel.git" # Track git repo
gem 'uuid'
gem 'resque'
gem 'resque-scheduler', :require => "resque_scheduler"

group :development do
  gem 'nifty-generators'
  gem 'ruby-debug19'
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test, :development do
  gem 'rspec-rails',        :git => 'git://github.com/rspec/rspec-rails.git'
  gem 'rspec',              :git => 'git://github.com/rspec/rspec.git'
  gem 'rspec-core',         :git => 'git://github.com/rspec/rspec-core.git'
  gem 'rspec-expectations', :git => 'git://github.com/rspec/rspec-expectations.git'
  gem 'rspec-mocks',        :git => 'git://github.com/rspec/rspec-mocks.git'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'factory_girl'
  gem 'spork', :git => 'git://github.com/timcharper/spork.git'
  gem 'capybara', :git => 'git://github.com/jnicklas/capybara.git'
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'timecop'
  gem 'launchy'
  gem 'resque_spec', :require => 'resque_spec/scheduler'
  gem 'guard-rspec'
  gem 'guard-spork'
end

