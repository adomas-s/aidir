class Formatter

  def initialize
  end

  def caption(title)
    "--- #{cyan_start}#{title}#{color_end} ---\n"
  end

  def table_header(col1, col2, col3)
    sprintf(header_format, col1, col2, col3)
  end

  def method_row(method, info)
    current = info[:current]
    if info[:flag]
      contents = flag_output(info[:flag])
    else
      contents = diff_output(info[:diff])
    end
    sprintf(method_row_format, contents, current_output(current), method)
  end

  def current_output(score)
    sprintf(current_format, current_prefix(score), score, color_end)
  end

  def metric_header(metric)
    sprintf(metric_format, "#{cyan_start}#{metric}#{color_end}")
  end

  def file_metric_row(metric, info)
    filename = info[:file]
    diff = info[:diff]
    if metric == 'flog total'
      current = total_current_output(info[:current])
    elsif metric == 'flog/method average'
      current = avg_current_output(info[:current])
    end
    sprintf(method_row_format, diff_output(diff), current, filename)
  end

  def total_current_output(score)
    sprintf(current_format, "", score, "")
  end

  def avg_current_output(score)
    sprintf(current_format, current_prefix(score), score, color_end)
  end

  private

  def diff_output(score)
    sprintf(diff_format, diff_prefix(score), score, color_end)
  end

  def flag_output(flag)
    sprintf(flag_format, flag) # TODO: .to_s?
  end

  def header_format
    @header_format ||= "%18s%10s   %-90s\n"
  end

  def diff_format
    @diff_format ||= "%s%18.1f%s"
  end

  def current_format
    @current_format ||= "%s%10.1f%s"
  end

  def method_row_format
    @method_row_format ||= "%s%s   %-90s\n"
  end

  def flag_format
    @flag_format ||= "%18s"
  end

  def metric_format
    @metric_format ||= "%-18s\n"
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

end
