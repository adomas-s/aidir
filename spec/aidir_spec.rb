require 'spec_helper'

describe Aidir do
  before(:all) do
    ensure_git_credentials
  end

  before(:each) do
    @repository, @not_repository, @repository_clone = prepare_directories
    @aidir = Aidir.new
  end

  after(:each) do
    delete_directories_and_contents
  end

  describe 'start' do
    it 'fails with git errors when not in a repository' do
      not_in_repository do
        results = @aidir.start
        results.size.should eql 1
        results.first.should include "fatal: Not a git repository"
      end
    end
    it 'does not throw errors when in a repository' do
      in_repository do
        @aidir.start.should eql nil
      end
    end
  end

  describe 'get_flog_results' do
  end

  describe 'prepare_git' do
    it 'returns errors in non-repository' do
      not_in_repository do
        results = @aidir.prepare_git
        results.size.should eql 1
        results.first.should include "fatal: Not a git repository"
      end
    end
    it 'returns nil in repository' do
      in_repository do
        @aidir.prepare_git.should eql nil
      end
    end
  end

end
