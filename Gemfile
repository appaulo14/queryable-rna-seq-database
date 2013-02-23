source 'https://rubygems.org'
ruby '1.9.3'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'mysql2'
# gem 'thin'
#gem 'sinatra'
#gem 'sequenceserver'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

#NOTE: Update the CDN for jquery in views/application.html.erb
#    to the lastest version when updating this
gem 'jquery-rails', '2.1.3'

gem 'heroku'

#gem 'activerecord-tableless', '>= 1.0.1'

group :bioinformatics do
    gem 'bio', '1.4.2'
    #gem 'goruby'
end

group :development do
  gem 'rspec-rails', '>= 2.0.1'
  gem 'annotate'
  #gem 'railroady'
  #gem 'umlify'
end

group :test do
  gem 'rspec',  '>= 2.0.1'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'capybara', '2.0.2'
  gem 'capybara-webkit'
#   gem 'railroady'
#   gem 'umlify'
  #gem 'poltergeist'
end

gem 'faker'

gem "galetahub-simple_captcha", :require => "simple_captcha"

#For foreigner key constraints. 
#       Unfortunately, it doesn't have cascading updates from what I can ascertain.
#gem 'foreigner'

gem 'json', '1.7.7'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
gem 'debugger'

gem 'devise', '2.2.2'

