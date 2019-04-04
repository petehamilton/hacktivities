source :rubygems

gem 'rake'
gem 'sinatra'
gem 'therubyracer'
gem 'haml'
gem 'less'
gem 'rack-coffee'
gem 'thin'
gem 'dalli'
gem 'nokogiri'

gem 'activesupport'

gem 'activerecord'
gem 'sinatra-activerecord' # excellent gem that ports ActiveRecord for Sinatra

# Sass & Compass
gem 'sass', '~> 3.7.4'
gem 'compass', '~> 0.11.6'

# Sass libraries
gem 'grid-coordinates', '~> 1.1.4'

group :development, :test do
  gem 'sqlite3'
  gem 'shotgun'
end

group :production do
  gem 'pg' # this gem is required to use postgres on Heroku
end
