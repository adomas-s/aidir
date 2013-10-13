class Scoreboard

  def initialize(raw_data)
    @raw_data = raw_data
    @diff_data = {}
    @file_data = {}
    @method_data = {}
    @output = ''
  end

  def results
    get_relevant_scores
    if @method_data.empty?
      print_no_diffs
      return
    end
    print_method_board
    print_file_board
    @output
  end

  private

  def get_relevant_scores
    get_diffs
    split_scores_by_type
    sort_scores
  end

  def diff_format
    @diff_format ||= "%s%18.1f%s"
  end

  def current_format
    @current_format ||= "%s%10.1f%s"
  end

  def diff_output(score)
    sprintf(diff_format, diff_prefix(score), score, color_end)
  end

  def current_output(score)
    sprintf(current_format, current_prefix(score), score, color_end)
  end

  def total_current_output(score)
    sprintf(current_format, "", score, "")
  end

  def avg_current_output(score)
    sprintf(current_format, current_prefix(score), score, color_end)
  end

  def head_format
    @head_format ||= "%18s%10s   %-90s\n"
  end

  def print_method_board
    @output << "--- #{cyan_start}METHOD SCORES#{color_end} ---\n"

    @output << sprintf(head_format, "Diff from master", "Current", "Method")
    format = "%s%s   %-90s\n"

    @method_data.each do |method, info|
      current = info[:current]
      unless info[:flag]
        diff = info[:diff]
        @output << sprintf(format, diff_output(diff), current_output(current), method)
      else
        flag_output = sprintf("%18s", info[:flag].to_s)
        @output << sprintf(format, flag_output, current_output(current), method)
      end
    end
  end

  def print_file_board
    @output << "--- #{cyan_start}FILE SCORES#{color_end} ---\n"

    @output << sprintf(head_format, "Diff from master", "Current", "Method")
    format = "%s%s   %-90s\n"

    @file_data.each do |metric, files|
      @output << sprintf("%-18s\n", "#{cyan_start}#{metric}#{color_end}")
      files.each do |file|
        filename = file[:file]
        diff = file[:diff]
        current = file[:current]
        if metric == "flog total"
          @output << sprintf(format, diff_output(diff), total_current_output(current), filename)
        else
          @output << sprintf(format, diff_output(diff), avg_current_output(current), filename)
        end
      end
    end
  end

  def print_no_diffs
    @output << "#{cyan_start}No changes detected#{color_end}\n"
  end

  def diff_prefix(score)
    if score < 0
      green_start
    elsif score < 5
      yellow_start
    else
      red_start
    end
  end

  def current_prefix(score)
    if score < 20
      green_start
    elsif score < 40
      yellow_start
    else
      red_start
    end
  end

  def cyan_start
    "\033[36m"
  end

  def red_start
    "\033[31m"
  end

  def yellow_start
    "\033[33m"
  end

  def green_start
    "\033[32m"
  end

  def color_end
    "\033[0m"
  end

  def split_scores_by_type
    @method_data = @diff_data
    file_keys.each do |key|
      @file_data[key] = @method_data.delete(key)
    end
  end

  def get_diffs
    @raw_data.each do |file, lines|
      lines.each do |metric, scores|
        score = diff(scores[:branch], scores[:master])
        next if score == 0.0
        @diff_data[metric] ||= []
        flag = nil
        if [:new, :deleted].include?(score)
          flag = score
          score = 0.0
        end
        @diff_data[metric] << {
          file: file,
          diff: score,
          current: scores[:branch],
          flag: flag
        }
      end
    end
  end

  def sort_scores
    return if @method_data.empty?
    file_keys.each do |key|
      @file_data[key].sort_by! { |f| -f[:diff] }
    end
    sorted_methods = @method_data.sort_by { |_, data| -data[0][:diff] }.flatten
    @method_data = Hash[*sorted_methods]
  end

  def diff(branch, master)
    if master and branch
      (branch - master).round(2)
    elsif branch
      :new
    else
      :deleted
    end
  end

  def file_keys
    [
      'flog total',
      'flog/method average'
    ]
  end

end
