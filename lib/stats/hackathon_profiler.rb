module HacktivityStats
  class HackathonProfiler
    def initialize(hackathon)
      @hackathon = hackathon
    end

    def get_stats
      repository_profilers = @hackathon.repositories.map{ |r| RepositoryProfiler.new(r) }
      return {} if repository_profilers.empty?

      hack_stats = {
        timed_stats: {},
        total_participants: 0
      }

      # Totals
      running_total = 0
      repository_profilers.each do |rp|
        rstats = rp.get_stats
        hack_stats[:total_participants] += rstats[:participant_count]
        rstats[:timed_stats].each do |timestamp, tstats|
          timed_stats = rstats[:timed_stats]
          running_total += tstats[:commits]
          hack_stats[:timed_stats][timestamp] ||= Hash.new(0)
          hack_stats[:timed_stats][timestamp][:commit_count] += tstats[:commits]
          hack_stats[:timed_stats][timestamp][:total_commits] = running_total
          hack_stats[:timed_stats][timestamp][:average_message_length] += tstats[:average_message_length]
          hack_stats[:timed_stats][timestamp][:total_swearword_count] += tstats[:swearword_count][:total]
        end
      end

      # Averages
      hack_stats[:timed_stats].each do |timestamp, stats|
        stats[:average_commits] = stats[:commit_count] / repository_profilers.size
        stats[:average_swearword_count] = stats[:total_swearword_count] / repository_profilers.size
      end
      hack_stats[:average_team_size] = hack_stats[:total_participants] / repository_profilers.size

      min_time = hack_stats[:timed_stats].keys.min
      max_time = hack_stats[:timed_stats].keys.max

      timed_stats = []
      hour = min_time
      prev_stats = {
          :commit_count => 0,
          :total_commits => 0,
          :average_message_length => 0,
          :total_swearword_count => 0,
          :average_commits => 0,
          :average_swearword_count => 0
      }
      while hour < max_time
        stats = hack_stats[:timed_stats][hour]
        stats ||= {
          :commit_count => 0,
          :total_commits => 0,
          :average_message_length => 0,
          :total_swearword_count => 0,
          :average_commits => 0,
          :average_swearword_count => 0
        }
        stats[:total_commits] += prev_stats[:total_commits]
        timed_stats.push({ :date => hour, :stats => stats })
        prev_stats = stats
        hour += 3600
      end

      hack_stats[:timed_stats] = timed_stats

      hack_stats[:redbull_cans] = 80
      hack_stats[:pizzas] = 65
      hack_stats[:common_words] = ["fixes", "works", "stuff", "hopefully", "hack"]

      commits = []
      repository_profilers.each do |rp|
        commits += rp.get_commits
      end

      commits.sort! { |a, b| b.time_bucket <=> a.time_bucket}
      hack_stats[:commits] = commits[0..5]
      hack_stats[:total_commits] = running_total
      return hack_stats
    end
  end
end
