require './app'
require 'sinatra/activerecord/rake'

task :seed do
  h = Hackathon.create({
    :name => "ICHack 2013",
    :twitter_widget_id => 300189295266893824
  })
  Repository.create({:hackathon_id => h.id, :original_url => "https://github.com/PeterHamilton/hacktivities"})

  h = Hackathon.create({:name => "DoCSoc Hack"})
  Repository.create({:hackathon_id => h.id, :original_url => "https://github.com/PeterHamilton/classy-cate"})
end
