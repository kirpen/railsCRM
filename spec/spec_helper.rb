require 'spork'

Spork.prefork do
  require 'simplecov'
  SimpleCov.start 'rails'
  
  ENV["RAILS_ENV"] ||= 'test'
  require "rails/mongoid"
  Spork.trap_class_method(Rails::Mongoid, :load_models) 
  
  require "rails/application"
  Spork.trap_method(Rails::Application, :reload_routes!)

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require "email_spec"
  require 'factory_girl'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    # config.use_transactional_fixtures = true  
    config.include Devise::TestHelpers, :type => :controller
    ActiveSupport::Dependencies.clear 
    
    # Clean up the database
    require 'database_cleaner'

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.orm = "mongoid"
    end

    config.before(:all) do
      DatabaseCleaner.start
    end

    config.after(:each) do  
      DatabaseCleaner.clean  
    end  
  end
end

Spork.each_run do
  FactoryGirl.definition_file_paths = [
          File.join(Rails.root, 'spec', 'factories')
  ]
  FactoryGirl.find_definitions 
end

def login_user
  @compant = Fabricate(:organisation)
  @user = Fabricate(:user, :organisation => @company)
  @user.confirm!
  sign_in @user
end
