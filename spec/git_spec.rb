require 'spec_helper'

describe Git do
  before(:all) do
    if `git config --get user.name`.empty?
      `git config --global user.name "Aidir Rspec"`
    end
    if `git config --get user.email`.empty?
      `git config --global user.email aidir@rspec.com`
    end
  end

  before(:each) do
    @repository = File.realdirpath('../aidir-git-repository')
    @not_repository = File.realdirpath('../aidir-not-a-git-repository')
    @repository_clone = File.realdirpath('../aidir-clone-repository')

    # Delete possible trash
    FileUtils.rm_rf(@repository)
    FileUtils.rm_rf(@not_repository)

    Dir.mkdir(@repository)
    Dir.mkdir(@repository_clone)
    Dir.chdir(@repository_clone) do
      `git init --bare`
    end
    Dir.chdir(@repository) do
      `git init`
    end
    Dir.mkdir @not_repository

    @git = Git.new
  end

  after(:each) do
    FileUtils.rm_rf(@repository)
    FileUtils.rm_rf(@not_repository)
    FileUtils.rm_rf(@repository_clone)
  end

  it 'returns errors' do
    @git.errors.should eql []
  end

  it 'returns changed files' do
    @git.changed_files.should eql []
  end

  describe 'is_repository?' do
    it 'recognizes repository' do
      in_repository do
        @git.is_repository?.should eql true
        @git.errors.should eql []
      end
    end

    it 'recognizes non-repository' do
      not_in_repository do
        @git.is_repository?.should eql false
        @git.errors.size.should eql 1
        @git.errors.first.should include "fatal: Not a git repository"
      end
    end
  end

  describe 'ruby_files' do
    it 'returns ruby files, skips other files' do
      create_and_push_first_file
      create_and_push_second_file_in_new_branch
      in_repository do
        File.open 'not-ruby.txt', 'w+'
        @git.ruby_files.should eql %w(file2.rb)
      end
    end
  end

  describe 'clear_cached_files' do
    it 'deletes cached files' do
      create_and_push_first_file
      create_and_push_second_file_in_new_branch
      create_and_push_third_file_in_current_branch
      in_repository do
        @git.ruby_files
        File.exists?('tmp/aidir_file2.rb').should eql true
        File.exists?('tmp/aidir_file3.rb').should eql true
        @git.clear_cached_files
        File.exists?('tmp/aidir_file2.rb').should eql false
        File.exists?('tmp/aidir_file3.rb').should eql false
      end
    end
  end

  # private

  describe 'all_changed_files' do

    context 'with expected workflow' do
      before(:each) do
        create_and_push_first_file
      end

      it 'should find new files' do
        create_and_push_second_file_in_new_branch

        in_repository do
          @git.send(:all_changed_files)
          @git.errors.should eql []
          @git.changed_files.should eql %w(file2.rb)
        end

        create_and_push_third_file_in_current_branch

        in_repository do
          @git.send(:all_changed_files)
          @git.errors.should eql []
          @git.changed_files.should eql %w(file2.rb file3.rb)
        end
      end

      it 'should find modified files' do
        in_repository do
          `git checkout -q -b modified_file`

          File.open 'file1.rb', 'w+' do |f|
            f.write "def loo\n'bar'\nend\n"
          end
          `git add -A && git commit -m "Modified first file"`

          @git.send(:all_changed_files)
          @git.errors.should eql []
          @git.changed_files.should eql %w(file1.rb)
        end
      end

      it 'should find removed files' do
         in_repository do
          `git checkout -q -b removed_file`

          File.delete 'file1.rb'
          `git add -A && git commit -m "Removed first file"`

          @git.send(:all_changed_files)
          @git.errors.should eql []
          @git.changed_files.should eql %w(file1.rb)
        end
      end
    end

    context 'with errors' do
      it 'should catch errors' do
        in_repository do
          File.open 'file1.rb', 'w+' do |f|
            f.write "def foo\n'bar'\nend\n"
          end
          `git add -A`
          `git commit -m "First file"`
          # Don't add origin, so origin/master gets lost

          @git.send(:all_changed_files)
          @git.errors.size.should eql 1
          @git.changed_files.should eql []
        end
      end
    end
  end

  describe 'filter_ruby_files' do
    it 'should leave only .rb files' do
      @git.send(:changed_files=, %w(Gemfile file1.rb app/file2.rb foo.ruby rb.))
      @git.send(:filter_ruby_files)
      @git.send(:changed_files).should eql %w(file1.rb app/file2.rb)
    end

    it 'should return empty array when no ruby files were changed' do
      @git.send(:changed_files=, %w(Gemfile))
      @git.send(:filter_ruby_files)
      @git.send(:changed_files).should eql []
    end
  end

  describe 'cache_files' do
    it 'should cache master file contents' do
      create_and_push_first_file
      in_repository do
        @git.changed_files = %w(file1.rb)
        @git.send(:cache_files)
        File.exists?('tmp/aidir_file1.rb').should eql true
      end
    end
  end

  describe 'remote_file_contents' do
    before(:each) do
      create_and_push_first_file
    end

    it 'returns contents of remotely existing file' do
      in_repository do
        remote = @git.send(:remote_file_contents, 'file1.rb')
        remote.should eql "def foo\n'bar'\nend\n"
      end
    end

    it 'returns empty string for files not in remote' do
      in_repository do
        remote = @git.send(:remote_file_contents, 'file2.rb')
        remote.should eql ""
      end
    end
  end

  describe 'temp' do
    it 'returns full path to cached file in repository root' do
      in_repository do
        filename = @git.send(:temp, 'fubar.rb')
        filename.should eql @repository + '/tmp/aidir_fubar.rb'
      end
    end

    it 'returns full path to cached file deep in repository' do
      in_repository do
        filename = @git.send(:temp, 'foo/bar/fubar.rb')
        filename.should eql @repository + '/tmp/aidir_foo_bar_fubar.rb'
      end
    end
  end

end
