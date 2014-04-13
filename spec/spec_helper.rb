if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end
require 'aidir'

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end


# Helper methods

def ensure_git_credentials
  if `git config --get user.name`.empty?
    `git config --global user.name "Aidir Rspec"`
  end
  if `git config --get user.email`.empty?
    `git config --global user.email aidir@rspec.com`
  end
end

def prepare_directories
  repository = File.realdirpath('../aidir-git-repository')
  not_repository = File.realdirpath('../aidir-not-a-git-repository')
  repository_clone = File.realdirpath('../aidir-clone-repository')

  # Delete possible trash
  FileUtils.rm_rf(repository)
  FileUtils.rm_rf(not_repository)

  Dir.mkdir(repository)
  Dir.mkdir(repository_clone)
  Dir.chdir(repository_clone) do
    `git init --bare`
  end
  Dir.chdir(repository) do
    `git init`
  end
  Dir.mkdir not_repository

  return repository, not_repository, repository_clone
end

def delete_directories_and_contents
  FileUtils.rm_rf(@repository)
  FileUtils.rm_rf(@not_repository)
  FileUtils.rm_rf(@repository_clone)
end

def create_and_push_first_file
  in_repository do
    File.open 'file1.rb', 'w+' do |f|
      f.write "def foo\n'bar'\nend\n"
    end
    `git add -A`
    `git commit -m "First file"`
    `git remote add origin #{@repository_clone}`
    `git push -q origin master`
  end
end

def create_and_push_second_file_in_new_branch
  in_repository do
    `git checkout -q -b new_file`

    # Create first new file
    File.open 'file2.rb', 'w+' do |f|
      f.write "def zoo\n'bar'\nend\n"
    end
    `git add -A && git commit -m "Second file"`
  end
end

def create_and_push_third_file_in_current_branch
  in_repository do
    # Create second new file
    File.open 'file3.rb', 'w+' do |f|
      f.write "def moo\n'darth'\nend\n"
    end
    `git add -A && git commit -m "Third file"`
  end
end

def in_repository
  Dir.chdir @repository do
    yield
  end
end

def not_in_repository
  Dir.chdir @not_repository do
    yield
  end
end
