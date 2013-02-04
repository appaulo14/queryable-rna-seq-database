# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  
#   Capybara::Server.class_eval do
#     def find_available_port
#       @port = 3000
#     end
#   end
  
  
#   Capybara.register_driver :ssl_selenium do |app|
#     profile = Selenium::WebDriver::Firefox::Profile.new
#     profile.assume_untrusted_certificate_issuer = false
#     Capybara::Selenium::Driver.new(app, :profile => profile)
#   end
#   
#   Capybara.default_driver = :ssl_selenium
  
  Capybara.run_server = false
  
  Capybara.server_port = 3000 
  Capybara.app_host = "https://0.0.0.0:3000/"
  
  def sign_in(user)
    visit new_user_session_path
    fill_in :user_email,    :with => user.email
    fill_in :user_password, :with => user.password
    click_button('Sign In')
  end
  
  def sign_in_as_nietz111()
    visit new_user_session_path
    find('#user_email').set('nietz111@ksu.edu')
    find('#user_password').set('cis895')
    click_button 'Sign in'
  end
  
  def sign_out()
    visit destroy_user_session_path
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
