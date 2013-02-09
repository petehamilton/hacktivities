module HacktivityStats
  class RepositoryProfiler
    def initialize(respository)
      @repository = respository
    end

    def get_raw_commits
      uri = URI.parse(@repository.commits_url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      raw_commits = JSON.parse(response.body)
      return raw_commits
    end

    def get_commits
      raw_commits = get_raw_commits
      commits = raw_commits.map{ |c| Commit.new(c) }
      return commits
    end

    def get_stats_for_commits
      commits = get_commits
      return commits.map{ |c| c.stats }
    end

    def get_stats
      commit_stats = get_stats_for_commits
      countable_keys = [:message_length, :swearword_count]

      # Calculate bucket totals
      time_buckets = {}
      commit_stats.each do |s|
        t = s[:time]

        time_buckets[t] ||= {}
        time_buckets[t][:commits] ||= 0
        time_buckets[t][:commits] += 1

        countable_keys.each do |k|
          time_buckets[t][k] ||= Hash.new(0)
          time_buckets[t][k][:total] += s[k]
        end
      end

      # Calculate averages
      time_buckets.each do |k, v|
        countable_keys.each{ |k| v[k][:average] = v[k][:total] / v[:commits] }
      end

      time_buckets.each do |k, tb|
        tb[:average_message_length] = tb[:message_length][:average]
        tb.delete(:message_length)
      end

      return time_buckets
    end
  end
end
