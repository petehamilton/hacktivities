module HacktivityStats
  class HackathonProfiler
    def initialize(hackathon)
      @hackathon = hackathon
    end

    def get_stats
      repository_profilers = @hackathon.repositories.map{ |r| RepositoryProfiler.new(r) }
      return {} if repository_profilers.empty?
      hack_stats = {}
      repository_profilers.each do |rp|
        rp.get_stats.each do |timestamp, rstats|
          hack_stats[timestamp] ||= Hash.new(0)
          hack_stats[timestamp][:total_commits] += rstats[:commits]
          hack_stats[timestamp][:average_message_length] += rstats[:average_message_length]
          hack_stats[timestamp][:total_swearword_count] += rstats[:swearword_count][:total]
        end
      end
      hack_stats.each do |timestamp, stats|
        stats[:average_commits] = stats[:total_commits] / repository_profilers.size
        stats[:average_swearword_count] = stats[:total_swearword_count] / repository_profilers.size
      end
      return hack_stats
    end
  end
end
