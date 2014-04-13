require_relative 'aidir/git'
require_relative 'aidir/flog'
require_relative 'aidir/formatter'
require_relative 'aidir/scoreboard'
require 'open3'

class Aidir

  def self.start
    @git = Git.new
    if @git.is_repository? and @git.errors.any?
      puts @git.errors and return
    end

    scoreboard = Scoreboard.new(get_flog_results)
    print scoreboard.results
  end

  def get_flog_results
    results = {}

    @git.ruby_files.each do |file|
      flog = Flog.new(file)
      results[file] = flog.analyze
    end
    @git.clear_cached_files

    results
  end

end
