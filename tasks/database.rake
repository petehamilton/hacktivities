require './app'
require 'sinatra/activerecord/rake'

task :seed do
  h = Hackathon.create({:name => "ICHack 2013"})
  Repository.create({:hackathon_id => h.id, :original_url => "https://github.com/PeterHamilton/hacktivity"})

  h = Hackathon.create({:name => "DoCSoc Hack"})
  Repository.create({:hackathon_id => h.id, :original_url => "https://github.com/PeterHamilton/classy-cate"})
end
