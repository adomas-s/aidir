class Git

  attr_accessor :errors, :changed_files

  def initialize
    @errors = []
    @changed_files = []
  end

  def is_repository?
    error = false
    Open3.popen3('git rev-parse') do |_, _, stderr|
      error = stderr.read
      @errors << error unless error.empty?
    end
  end

  def ruby_files
    all_changed_files
    filter_ruby_files
    cache_files
    @changed_files
  end

  def clear_cached_files
    @changed_files.each do |file|
      File.delete(temp(file))
    end
  end

  private

  def all_changed_files
    Open3.popen3("git diff --name-only origin/master...") do |_, stdout, stderr|
      error = stderr.read
      @errors << error and return unless error.empty?
      out = stdout.read
      @changed_files = out.split("\n") unless out.empty?
    end
  end

  def filter_ruby_files
    @changed_files.reject! { |filename| filename[-3..-1] != '.rb' }
  end

  def cache_files
    @changed_files.each do |file|
      File.open(temp(file), 'w') do |f|
        f.write(remote_file_contents(file))
      end
    end
  end

  def remote_file_contents(file)
    Open3.popen3("git show origin/master:#{file}") do |_, stdout, stderr|
      stdout.read
    end
  end

  def temp(file)
    safe_filename = file.gsub('/', '_')
    "#{Dir.pwd}/tmp/aidir_#{safe_filename}"
  end

end
