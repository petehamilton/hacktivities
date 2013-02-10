require 'rubygems'
require 'sinatra'
require 'active_record'
require 'sinatra/activerecord'
require 'haml'
require 'less'
require 'json'
require 'open-uri'
require 'uri'
require 'nokogiri'
require 'net/http'
require 'net/https'
require 'dalli'

# Helpers
require './config/environments'
require './config/cache'
require './config/profanity'

# Models
require './models/hackathon'
require './models/repository'

# Library code
require './lib/render_partial'
require './lib/round_time'

# Stats
require './lib/stats/hackathon_profiler'
require './lib/stats/repository_profiler'
require './lib/stats/commit'

# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public_folder, 'public'
set :haml, {:format => :html5} # default Haml format is :xhtml

# Assets
get '/application.css' do
  get_cache('application-css', 600) {
    less :application
  }
end

get '/application.js' do
  get_cache('application-js', 600) {
    coffee :application
  }
end

# Pages
get '/' do
  redirect '/hackathons'
end

get '/hackathons' do
  @hackathons = Hackathon.all
  haml :hackathons, :layout => :'layouts/application'
end

get '/hackathons/:id/data.json' do
  content_type :json
  begin
    @hackathon = Hackathon.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return {error: "Invalid Hackathon ID"}.to_json
  end

  begin
    hackathon_profiler = HacktivityStats::HackathonProfiler.new(@hackathon)
    hackathon_profiler.get_stats.to_json
  rescue HacktivityStats::GithubRateError, JSON::ParserError
    return {api_error: true}.to_json
  end
end

get '/hackathons/:hackathon_id' do
  begin
    @hackathon = Hackathon.find(params[:hackathon_id])
  rescue ActiveRecord::RecordNotFound
    haml :repositories, :layout => :'layouts/application'
  end
  @repository = Repository.new({:hackathon_id => @hackathon.id})
  @repositories = @hackathon.repositories
  haml :repositories, :layout => :'layouts/application'
end

post '/hackathons/:hackathon_id/repositories' do
  begin
    @hackathon = Hackathon.find(params[:hackathon_id])
  rescue ActiveRecord::RecordNotFound
    haml :repositories, :layout => :'layouts/application'
  end

  @repository = Repository.new(params[:repository])
  @repository.hackathon_id = @hackathon.id
  @repository.original_url = @repository.original_url.gsub('.git', '')

  if @repository.save
    redirect "/hackathons/#{@hackathon.id}"
  else
    @repositories = @hackathon.repositories
    haml :repositories, :layout => :'layouts/application'
  end
end

delete '/repositories/:id' do
  begin
    @repository = Repository.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    return { error: "Repository not found" }.to_json
  end
  @repository.destroy
end
