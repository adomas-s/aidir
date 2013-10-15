require_relative 'aidir/git'
require_relative 'aidir/flog'
require_relative 'aidir/formatter'
require_relative 'aidir/scoreboard'
require 'open3'

class Aidir

  def self.start
    @errors = []
    @results = {}
    git = nil
    files = nil

    git = Git.new(@errors)
    git.is_repository?
    if @errors.any?
      puts @errors
      return
    end

    files = git.ruby_files

    files.each do |file|
      flog = Flog.new(file)
      @results[file] = flog.analyze
    end

    git.clear_cached_files

    scoreboard = Scoreboard.new(@results)
    print scoreboard.results
  end

end
