module HacktivityStats
  class GithubRateError < StandardError; end
  class RepositoryProfiler
    def initialize(respository)
      @repository = respository
    end

    def get_raw_commits
      get_cache("raw-commits-#{@repository.id}", 60) {
        uri = URI.parse(@repository.commits_url)

        puts "REQUESTING #{uri.to_s}"

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(uri.request_uri)

        response = http.request(request)
        result = JSON.parse(response.body)
        if !result.kind_of?(Array) && result.keys.include?('message') && result['message'].include?("API Rate Limit Exceeded")
          raise HacktivityStats::GithubRateError
        end
        JSON.parse(response.body)
      }
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

      committers = []

      # Calculate bucket totals
      time_buckets = {}
      commit_stats.each do |s|
        committers.push(s[:committer_login])

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

      return {
        timed_stats: time_buckets,
        participant_count: committers.uniq.size
      }
    end
  end
end
