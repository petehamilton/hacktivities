module HacktivityStats
  class Commit
    def initialize(commit)
      @commit = commit
    end

    def stats
      _swearwords = swearwords
      _message = message
      return {
        time: time_bucket,
        message: _message,
        message_length: _message.length,
        swearwords: _swearwords,
        swearword_count: _swearwords.size,
        committer_login: committer_login
      }
    end

    def message
      @commit['commit']['message']
    end

    def committer_login
      begin
        @commit['committer']['login']
      rescue
        ''
      end
    end

    def time
      @commit['commit']['committer']['date'].to_time
    end

    def time_bucket
      time.round(1.hour)
    end

    def swearwords
      words = []
      settings.profanities.each do |word|
         words.push(word) if (message =~ /\b#{word}\b/i)
      end
      return words
    end
  end
end
