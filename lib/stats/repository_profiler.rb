module HacktivityStats
  class GithubRateError < StandardError; end
  class RepositoryProfiler
    def initialize(respository)
      @repository = respository
    end

    def get_raw_commits
      done = false
      get_cache("raw-commits-#{@repository.id}", 60) {
        original_url = @repository.commits_url
        url = original_url
        commits = []
        while !done
          uri = URI.parse(url)
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

          cs = JSON.parse(response.body)
          commits += cs
          url = original_url + "&sha=#{commits.last['sha']}"
          done = cs.length == 1
        end
        commits
      }
    end

    def get_commits
      raw_commits = get_raw_commits
      commits = raw_commits.map{ |c| Commit.new(c) }
      return commits.sort { |a, b| b.time_bucket <=> a.time_bucket}
    end

    def get_stats_for_commits
      commits = get_commits
      return commits.map{ |c| c.stats }
    end

    def get_stats
      all_commit_stats = get_stats_for_commits

      time_buckets = {}
      popular_words = Hash.new(0)
      all_commit_stats.each do |commit_stat|
        commit_time_bucket = commit_stat[:time_bucket]
        time_buckets[commit_time_bucket] ||= {}

        time_buckets[commit_time_bucket][:commit_count] ||= 0
        time_buckets[commit_time_bucket][:commit_count] += 1

        time_buckets[commit_time_bucket][:total_message_length] ||= 0
        time_buckets[commit_time_bucket][:total_message_length] += commit_stat[:message_length]

        time_buckets[commit_time_bucket][:swearword_count] ||= 0
        time_buckets[commit_time_bucket][:swearword_count] += commit_stat[:swearword_count]

        time_buckets[commit_time_bucket][:committers] ||= []
        time_buckets[commit_time_bucket][:committers].push(commit_stat[:committer_login]).uniq!

        time_buckets[commit_time_bucket][:word_frequencies] ||= Hash.new(0)
        commit_stat[:word_frequencies].each do |w, f|
          time_buckets[commit_time_bucket][:word_frequencies][w] += f
        end
      end

      return time_buckets
    end
  end
end
