require_relative 'aidir/git'
require_relative 'aidir/aidir_flog'
require_relative 'aidir/formatter'
require_relative 'aidir/scoreboard'
require 'open3'

class Aidir

  def initialize
  end

  def start
    git_errors = prepare_git
    if git_errors
      puts git_errors
      return git_errors
    end

    scoreboard = Scoreboard.new(get_flog_results)
    results = scoreboard.results
    print results
    return results
  end

  def get_flog_results
    results = {}

    @git.ruby_files.each do |file|
      flog = AidirFlog.new(file)
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
