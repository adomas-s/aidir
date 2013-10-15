class Formatter

  def initialize
  end

  def caption(title)
    "\n--- #{colors[:cyan]}#{title}#{color_end} ---\n"
  end

  def table_header(col1, col2, col3)
    sprintf(format[:header], col1, col2, col3)
  end

  def method_row(method, info)
    current = info[:current]
    if info[:flag]
      contents = flag_output(info[:flag])
    else
      contents = diff_output(info[:diff])
    end
    sprintf(format[:method_row], contents, current_output(current), method)
  end

  def current_output(score)
    sprintf(format[:current], current_prefix(score), score, color_end)
  end

  def metric_header(metric)
    sprintf(format[:metric], "#{colors[:cyan]}#{metric}#{color_end}")
  end

  def file_metric_row(metric, info)
    filename = info[:file]
    diff = info[:diff]
    if metric == 'flog total'
      current = total_current_output(info[:current])
    elsif metric == 'flog/method average'
      current = avg_current_output(info[:current])
    end
    sprintf(format[:method_row], diff_output(diff), current, filename)
  end

  def total_current_output(score)
    sprintf(format[:current], '', score, '')
  end

  def avg_current_output(score)
    sprintf(format[:current], current_prefix(score), score, color_end)
  end

  private

  def diff_output(score)
    sprintf(format[:diff], diff_prefix(score), score, color_end)
  end

  def flag_output(flag)
    sprintf(format[:flag], flag)
  end

  def format
    @format ||= {
      header:     "%18s%10s   %-90s\n",
      diff:       "%s%18.1f%s",
      current:    "%s%10.1f%s",
      method_row: "%s%s   %-90s\n",
      flag:       "%18s",
      metric:     "%-18s\n"
    }
  end

  # Score coloring logic

  def diff_prefix(score)
    if score < 0
      colors[:green]
    elsif score < 5
      colors[:yellow]
    else
      colors[:red]
    end
  end

  def current_prefix(score)
    if score < 20
      colors[:green]
    elsif score < 40
      colors[:yellow]
    else
      colors[:red]
    end
  end

  # ASCII rainbows and unicorns go here

  def colors
    @colors ||= {
      cyan:   "\033[36m",
      red:    "\033[31m",
      yellow: "\033[33m",
      green:  "\033[32m"
    }
  end

  def color_end
    @color_end ||= "\033[0m"
  end

end
