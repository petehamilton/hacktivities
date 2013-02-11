module HacktivityStats
  class Commit
    def initialize(commit)
      @commit = commit
    end

    def stats
      return {
        time_bucket: time_bucket,
        word_frequencies: word_frequencies,
        message_length: message.length,
        swearwords: swearwords,
        swearword_count: swearwords.size,
        committer_login: committer_login
      }
    end

    def word_frequencies
      word_freqs = Hash.new(0)
      @commit['commit']['message'].split.each do |word|
        word_freqs[word] += 1
      end
      return word_freqs
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
