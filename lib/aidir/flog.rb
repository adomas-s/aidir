class Flog

  def initialize(filename)
    @branch = filename
    @master = temp(filename)
    @flog_data = {}
    @results = {}
  end

  def analyze
    flog_both
    parse_flog_data
    @results
  end

  private

  def flog_both
    @flog_data[:branch] = flog_file(@branch)
    @flog_data[:master] = flog_file(@master)
  end

  def parse_flog_data
    @flog_data.each do |branch, branch_data|
      data = raw_to_hash(branch_data)
      data.each do |key, val|
        @results[key] ||= {}
        @results[key][branch] = val
      end
    end
  end

  def flog_file(filename)
    Open3.popen3("flog -a #{filename}") do |_, stdout, stderr|
      stdout.read
    end
  end

  def raw_to_hash(data)
    lines = string_to_line_arr(data)
    lines = values_to_floats(lines)
    lines[2..-1] = clean_method_names(lines[2..-1]) # clean methods from paths
    Hash[*lines.flatten]
  end

  def temp(file)
    safe_filename = file.gsub('/', '_')
    "#{Dir.pwd}/tmp/aidir_#{safe_filename}"
  end

  def string_to_line_arr(string)
    string.split("\n")
      .reject { |l| l.empty? }
      .map! { |l| l.strip.split(": ").reverse }
  end

  def values_to_floats(lines)
    lines.map do |line|
      [
        line[0],
        line[1].to_f
      ]
    end
  end

  def clean_method_names(lines)
    lines.map do |line|
      [
        line[0].split.first,
        line[1]
      ]
    end
  end

end
