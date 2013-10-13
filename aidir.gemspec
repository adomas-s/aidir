# encoding: UTF-8
Gem::Specification.new do |s|
  s.name        = 'aidir'
  s.version     = '0.0.1'
  s.date        = '2013-10-13'
  s.summary     = "Shows Flog score diff of current git branch vs. origin/master"
  s.description = "aidir - Am I Doing It Right: track and improve your Flog (http://ruby.sadi.st/Flog.html) score before merging code to master by getting Flog score differences between current branch and master branch"
  s.authors     = ['Adomas Sliužinskas']
  s.email       = 'adomas.sliuzinskas@gmail.com'
  s.homepage    = 'http://github.com/adomas-s/aidir'
  s.license     = 'MIT'
  s.executables = ['aidir']

  s.files       = %w[
    lib/aidir.rb
    lib/aidir/flog.rb
    lib/aidir/git.rb
    lib/aidir/scoreboard.rb
  ]

  s.add_runtime_dependency("flog", "~> 4.1.2")
  s.add_development_dependency("flog", "~> 4.1.2")
end
