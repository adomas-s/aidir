require 'flog_cli'
require 'benchmark'

filename = "lib/aidir.rb"

argv = ['-a', filename]

def cli(filename)
  out = StringIO.new
  args = ['-a', filename]
  options = FlogCLI.parse_options(args)
  flogger = FlogCLI.new(options)
  flogger.flog(args)
  flogger.report(out)
  out.string
end

x = 10

ruby_time = Benchmark.realtime do
  x.times do
    cli(filename)
  end
end

exec_time = Benchmark.realtime do
  x.times do
    `flog -a #{filename}`
  end
end

puts "FlogCLI via Ruby:   #{ruby_time}"
puts "Executing `flog`:   #{exec_time}"
puts "------------------------------"
puts "Ruby way is #{exec_time / ruby_time} times faster"
