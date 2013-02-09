# Load profanities for swearword checking
set :profanities, []
begin
  open('https://raw.github.com/tjackiw/obscenity/master/config/blacklist.yml') do |f|
    set :profanities, YAML.load(f)
  end
rescue
  logger.error "Couldn't load profanities"
end
