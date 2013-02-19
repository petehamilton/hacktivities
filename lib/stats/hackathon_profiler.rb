module HacktivityStats
  class HackathonProfiler
    def initialize(hackathon)
      @hackathon = hackathon
    end

    def get_stats
      repository_profilers = @hackathon.repositories.map{ |r| RepositoryProfiler.new(r) }
      return {} if repository_profilers.empty?

      # Totals
      time_buckets = {}
      committers = []
      commits = []
      word_frequencies = Hash.new(0)
      repository_profilers.each do |rp|
        commits += rp.get_commits
        rp.get_stats.each do |timestamp, tstats|
          committers += tstats[:committers]
          time_buckets[timestamp] ||= Hash.new(0)
          time_buckets[timestamp][:commit_count] += tstats[:commit_count]
          time_buckets[timestamp][:total_message_length] += tstats[:total_message_length]
          time_buckets[timestamp][:total_swearword_count] += tstats[:swearword_count]
          tstats[:word_frequencies].each do |w, f|
            word_frequencies[w] += f
          end
        end
      end
      commits.sort! { |a, b| b.time_bucket <=> a.time_bucket}
      committers.uniq!

      # Averages
      time_buckets.each do |timestamp, stats|
        stats[:average_message_length] = (1.0 * stats[:total_message_length] / repository_profilers.size).ceil
        stats[:average_commits] = (1.0 * stats[:commit_count] / repository_profilers.size).ceil
        stats[:average_swearword_count] = (1.0 * stats[:total_swearword_count] / repository_profilers.size).ceil
      end

      min_time = time_buckets.keys.min
      max_time = min_time + 2.days

      empty_stats = {
        :commit_count => 0,
        :total_commits => 0,
        :average_message_length => 0,
        :total_swearword_count => 0,
        :average_commits => 0,
        :average_swearword_count => 0
      }

      timed_stats = []
      hour = min_time
      prev_stats = empty_stats.dup
      while hour < max_time
        stats = time_buckets[hour]
        stats ||= empty_stats.dup
        stats[:total_commits] = prev_stats[:total_commits] + stats[:commit_count]
        timed_stats.push({ :timestamp => hour, :stats => stats })
        prev_stats = stats
        hour += 3600
      end

      hack_stats = {}
      hack_stats[:timed_stats] = timed_stats
      hack_stats[:total_participants] = committers.size
      hack_stats[:average_team_size] = committers.size / repository_profilers.size
      hack_stats[:commits] = commits[0..5]
      hack_stats[:total_commits] = timed_stats.last[:stats][:total_commits]
      hack_stats[:common_words] = word_frequencies.sort_by{ |key, value| -value }[0..5].map{|x| x.first}
      hack_stats[:total_hours] = ((max_time - min_time) / 1.hour).round

      # TODO: Pull from Database/Live Data
      hack_stats[:redbull_cans] = @hackathon.redbull_cans_drunk
      hack_stats[:pizzas] = @hackathon.pizzas_eaten

      return hack_stats
    end
  end
end
