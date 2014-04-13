require_relative 'aidir/git'
require_relative 'aidir/flog'
require_relative 'aidir/formatter'
require_relative 'aidir/scoreboard'
require 'open3'

class Aidir

  def initialize
    start
  end

  def start
    git_errors = prepare_git
    if git_errors
      puts git_errors
      return git_errors
    end

    scoreboard = Scoreboard.new(get_flog_results)
    print scoreboard.results
    return scoreboard.results
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

  def prepare_git
    @git = Git.new
    return @git.errors unless @git.is_repository?
  end

end
