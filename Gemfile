source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
#gem 'mysql2'
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

#You may need to update the CDN for jquery in views/application.html.erb
#    to the lastest version when updating this
gem 'jquery-rails', '2.1.3'

gem 'heroku'

gem 'activerecord-tableless', '>= 1.0.1'

group :bioinformatics do
    gem 'bio', '1.4.2'
    #gem 'goruby'
end

group :development do
  gem 'rspec-rails', '>= 2.0.1'
  gem 'annotate'
end

group :test do
  gem 'rspec',  '>= 2.0.1'
  gem 'webrat', '>= 0.7.1'
  gem "factory_girl_rails", "~> 4.0"
end

#For foreigner key constraints. 
#       Unfortunately, it doesn't have cascading updates from what I can ascertain.
#gem 'foreigner'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
gem 'debugger'

