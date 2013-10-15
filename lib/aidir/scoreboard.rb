class Scoreboard

  def initialize(raw_data)
    @raw_data = raw_data
    @diff_data = {}
    @file_data = {}
    @method_data = {}
    @output = ''
    @formatter = Formatter.new
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

  def file_keys
    @file_keys ||= [
      'flog total',
      'flog/method average'
    ]
  end

  def get_relevant_scores
    get_diffs
    split_scores_by_type
    sort_scores
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
        score = calc_diff(scores[:branch], scores[:master])
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

  def calc_diff(branch, master)
    if master and branch
      (branch - master).round(2)
    elsif branch
      :new
    else
      :deleted
    end
  end

  def print_method_board
    @output << @formatter.caption('METHOD SCORES')
    @output << @formatter.table_header('Diff from master', 'Current', 'Method')

    @method_data.each do |method, info|
      @output << @formatter.method_row(method, info)
    end
  end

  def print_file_board
    @file_data.each do |metric, files|
      @output << @formatter.caption("FILE #{metric} SCORES")
      @output << @formatter.table_header('Diff from master', 'Current', 'File')
      files.each do |file_info|
        @output << @formatter.file_metric_row(metric, file_info)
      end
    end
  end

  def print_no_diffs
    @output << "#{colors[:cyan]}No changes detected#{color_end}\n"
  end


end
