class Formatter

  def caption(title)
    "\n--- #{colors[:cyan]}#{title}#{color_end} ---\n"
  end

  def table_header(col1, col2, col3)
    sprintf(format[:header], col1, col2, col3)
  end

  def method_row(method, info)
    current = info[:current]
    if info[:flag]
      contents = preformat_flag(info[:flag])
    else
      contents = preformat_delta(info[:delta])
    end
    sprintf(format[:method_row], contents, preformat_current(current), method)
  end

  def file_row(metric, info)
    filename = info[:file]
    delta = info[:delta]
    if metric == 'flog total'
      current = preformat_file_total(info[:current])
    elsif metric == 'flog/method average'
      current = preformat_file_avg(info[:current])
    end
    sprintf(format[:method_row], preformat_delta(delta), current, filename)
  end

  private

  # Preformatters

  def preformat_current(score)
    sprintf(format[:current], method_color(score), score, color_end)
  end

  def preformat_delta(score)
    sprintf(format[:delta], delta_color(score), score, color_end)
  end

  def preformat_flag(flag)
    sprintf(format[:flag], flag)
  end

  def preformat_file_total(score)
    sprintf(format[:current], '', score, '')
  end

  def preformat_file_avg(score)
    sprintf(format[:current], method_color(score), score, color_end)
  end

  # Format strings

  def format
    @format ||= {
      header:     "%18s%10s   %-90s\n",
      delta:      "%s%18.1f%s",
      current:    "%s%10.1f%s",
      method_row: "%s%s   %-90s\n",
      flag:       "%18s",
    }
  end

  # Score coloring logic

  def delta_color(score)
    delta_score_thresholds = [0, 5]
    score_color(score, delta_score_thresholds)
  end

  def method_color(score)
    method_score_thresholds = [20, 40]
    score_color(score, method_score_thresholds)
  end

  def score_color(score, thresholds)
    if score < thresholds[0]
      colors[:green]
    elsif score < thresholds[1]
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
