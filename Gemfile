source 'https://rubygems.org'

ruby '2.5.1'

gem 'dotenv-rails'  # Use .env file for secret keys

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>5.2.1'
gem 'responders'
gem 'bootsnap', require: false

gem 'appengine', group: :production

group :development, :test, :production do

  # CORS
  gem 'rack-cors', require: 'rack/cors'

  ##
  ## DATABASES
  ##
  gem 'pg', '~> 0.18'                # PostgreSQL by default
  

  ##
  ## USER AUTHENTICATION
  ##
  gem 'bcrypt'
  gem 'devise'           # Devise for authentication
  gem 'cancancan'        # And control access using cancan

  # We're moving away from omniauth to individual auth setups
  gem 'google-id-token'
  gem "knock"
  gem "redis"

  # Process user avatars from OAuth
  gem "mimemagic"

  # GraphiQL for exploring the schema
  gem 'graphiql-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'puma'

  # Use Countries to figure out country from country code
  # which can be used to figure out locale as well
  gem 'countries'

  ##
  ## REST API MANAGEMENT
  ##
  gem 'active_model_serializers'          # Serializers!

  ##
  ## APP SPECIFIC
  ##
  gem 'geokit'
  gem 'geokit-rails'                          # Make Locations mappable
  gem 'graphql'
  gem 'graphql-batch'
  gem 'graphql-preload'
  gem 'graphql-docs'
  gem 'graphql-cache'

  ##
  ## MISC
  ##
  gem 'faker'        # Generate fake data
  # gem 'rails-i18n'   # Translate stuff!
  #gem 'rails_config' # Custom config variables using Settings.config_variable
  gem 'config'
  gem 'wikipedia-client'  # Used for Achievement crawling, to create a nice description

  # For Achievement collection
  gem 'capybara'           # Capybara for testing User interaction
  gem 'selenium-webdriver' # Selenium for testing user interaction with JS
  gem 'poltergeist'        # Let Capybara use PhantomJS browser
end

group :development, :test do
  gem 'rspec-rails'        # For TDD
  gem 'factory_bot'       # Factory Girl for creating test data
  gem 'railroady'          # Generate UML diagrams
  gem 'rest-client'        # A RESTclient to try out actual REST communication
end


group :development do
  # Spring speeds up development by keeping your application running in the background.
  # Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'annotate'
  gem 'bullet'
  gem 'brakeman', require: false

  # Better console
  gem 'pry-rails'
  gem 'pry-byebug'

  
  # Linting
  gem "rubocop"
  gem "rubocop-rails_config"

  # Code completion in VSCode
  gem "solargraph"
end
