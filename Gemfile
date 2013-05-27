source 'https://rubygems.org'
ruby '1.9.3'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

   #See https://github.com/sstephenson/execjsreadme for more supported runtimes
   gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

#NOTE: Update the jquery.min.js file in vendor/assets/javascripts/jquery
# to the lastest version when updating this also. This needs to be done
# because of a strange bug where jquery.min.js takes a long time to load if 
# I use the version from the jquery-rails gem.
gem 'jquery-rails', '2.1.3'


gem 'bio', '1.4.2'


group :development do
  gem 'rspec-rails', '>= 2.0.1'
  gem 'annotate'
  gem 'debugger'
end

group :test do
  gem 'rspec',  '>= 2.0.1'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'capybara', '2.0.2'
  gem 'capybara-webkit'
  gem 'debugger'
  gem 'database_cleaner'
end

gem 'thin'
gem 'faker'

gem 'galetahub-simple_captcha', :require => 'simple_captcha'
gem 'sucker_punch'
gem 'composite_primary_keys'

gem 'json', '1.7.7'
gem 'execjs'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'


gem 'devise', '2.2.2'

