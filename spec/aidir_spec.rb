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
    before(:each) do
      create_and_push_first_file
    end
    it 'works with new files' do        create_and_push_second_file_in_new_branch
      in_repository do
        flog_results = @aidir.get_flog_results
        flog_results.keys.should eql %w(file2.rb)
        total2 = flog_results['file2.rb']['flog total']

        expect(total2[:branch]).to be > total2[:master]
      end

      create_and_push_third_file_in_current_branch
      in_repository do
        flog_results = @aidir.get_flog_results
        flog_results.keys.should eql %w(file2.rb file3.rb)
        total2 = flog_results['file2.rb']['flog total']
        total3 = flog_results['file3.rb']['flog total']

        expect(total2[:master]).to eql 0.0
        expect(total2[:branch]).to be > total2[:master]

        expect(total3[:master]).to eql 0.0
        expect(total3[:branch]).to eql total3[:master]
      end
    end
    it 'works with modified files' do
      modify_first_file_in_new_branch
      in_repository do
        flog_results = @aidir.get_flog_results
        flog_results.keys.should eql %w(file1.rb)
        total1 = flog_results['file1.rb']['flog total']

        expect(total1[:branch]).to be < total1[:master]
      end
    end
    it 'works with removed files' do
      remove_first_file_in_new_branch
      in_repository do
        flog_results = @aidir.get_flog_results
        flog_results.keys.should eql %w(file1.rb)
        total1 = flog_results['file1.rb']['flog total']

        expect(total1[:branch]).to eql 0.0
        expect(total1[:branch]).to be < total1[:master]
      end
    end
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
