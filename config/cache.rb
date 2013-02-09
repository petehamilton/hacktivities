# Default 10 minute cache
set :cache, Dalli::Client.new(nil, {:expires_in => 60*10})
