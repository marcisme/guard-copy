require 'spec_helper'
require 'guard/copy'
require 'fileutils'

module Guard
  describe Copy do

    describe '.initialize' do

      it 'converts single :to option to an array' do
        guard = Copy.new([], :to => 'target')
        guard.options[:to].should == ['target']
      end

      it 'preserves :to array' do
        guard = Copy.new([], :to => ['t1', 't2'])
        guard.options[:to].should == ['t1', 't2']
      end

      it 'preserves globs in :to array' do
        guard = Copy.new([], :to => ['t*'])
        guard.options[:to].should == ['t*']
      end

      it 'freezes :to array' do
        guard = Copy.new([], :to => 'target')
        guard.options[:to].should be_frozen
      end

      describe 'watchers' do

        it 'creates a single watcher with :from if no watchers are defined' do
          guard = Copy.new([], :from => 'source')
          guard.watchers.count.should == 1
          guard.watchers.first.pattern.source.should == '^source/.*$'
        end

        it 'preserves watchers that start with ^ and :from' do
          guard = Copy.new([Watcher.new(%r{^source/.+\.js$})], :from => 'source')
          guard.watchers.count.should == 1
          guard.watchers.first.pattern.source.should == '^source/.+\.js$'
        end

        it 'prepends watchers with ^' do
          guard = Copy.new([Watcher.new(%r{source/.+\.js$})], :from => 'source')
          guard.watchers.count.should == 1
          guard.watchers.first.pattern.source.should == '^source/.+\.js$'
        end

        it 'prepends watchers with :from' do
          guard = Copy.new([Watcher.new(%r{^.+\.js$})], :from => 'source')
          guard.watchers.count.should == 1
          guard.watchers.first.pattern.source.should == '^source/.+\.js$'
        end

        it 'prepends watchers with ^ and :from' do
          guard = Copy.new([Watcher.new(%r{.+\.js$})], :from => 'source')
          guard.watchers.count.should == 1
          guard.watchers.first.pattern.source.should == '^source/.+\.js$'
        end

        it 'informs when changing a watcher pattern' do
          UI.should_receive(:info).with('Guard::Copy is changing watcher pattern:')
          UI.should_receive(:info).with('  .+\.js$')
          UI.should_receive(:info).with('to:')
          UI.should_receive(:info).with('  ^source/.+\.js$')
          guard = Copy.new([Watcher.new(%r{.+\.js$})], :from => 'source')
        end

        it 'handles multiple watchers' do
          guard = Copy.new([
            Watcher.new(%r{^.+\.js$}),
            Watcher.new(%r{^.+\.html$})
          ], :from => 'source')
          watcher_sources = guard.watchers.map { |w| w.pattern.source }
          watcher_sources.should =~ ['^source/.+\.js$', '^source/.+\.html$']
        end

      end

    end

    describe '#start' do

      it 'throws :task_has_failed when :from is not provided' do
        guard = Copy.new
        UI.should_receive(:error).with('Guard::Copy - :from option is required')
        expect { guard.start }.to throw_symbol(:task_has_failed)
      end

      it 'throws :task_has_failed when :from directory does not exist' do
        guard = Copy.new([], :from => 'source')
        UI.should_receive(:error).with('Guard::Copy - :from option does not contain a valid directory')
        expect { guard.start }.to throw_symbol(:task_has_failed)
      end

      it 'throws :task_has_failed when :from directory is a file' do
        file('source')
        guard = Copy.new([], :from => 'source')
        UI.should_receive(:error).with("Guard::Copy - 'source' is a file and must be a directory")
        expect { guard.start }.to throw_symbol(:task_has_failed)
      end

      it 'throws :task_has_failed when :to is not provided' do
        dir('source')
        guard = Copy.new([], :from => 'source')
        UI.should_receive(:error).with('Guard::Copy - :to option is required')
        expect { guard.start }.to throw_symbol(:task_has_failed)
      end

      it 'throws :task_has_failed when :to includes :from' do
        dir('source')
        guard = Copy.new([], :from => 'source', :to => 'source')
        UI.should_receive(:error).with('Guard::Copy - :to must not include :from')
        expect { guard.start }.to throw_symbol(:task_has_failed)
      end

      it 'warns when a :to directory does not exist' do
        dir('source')
        dir('target')
        guard = Copy.new([], :from => 'source', :to => ['target', 'v*'])
        UI.should_receive(:warning).with("Guard::Copy - 'v*' does not match a valid directory")
        guard.start
      end

      it 'throws :task_has_failed when :to contains a file' do
        pending do
          dir('source')
          file('target')
          guard = Copy.new([], :from => 'source', :to => 'target')
          UI.should_receive(:error).with('Guard::Copy - :to option contains a file and must be all directories')
          expect { guard.start }.to throw_symbol(:task_has_failed)
        end
      end

      it 'resolves targets for paths in :to option' do
        dir('source')
        dir('target')
        guard = Copy.new([], :from => 'source', :to => 'target')
        guard.start
        guard.targets.should == ['target']
      end

      it 'resolves target globs in :to option' do
        dir('source')
        dir('t1')
        dir('t2')
        guard = Copy.new([], :from => 'source', :to => 't*')
        guard.start
        guard.targets.should == ['t1', 't2']
      end

      it 'displays :from and :to directories' do
        dir('source')
        dir('t1')
        dir('t2')
        guard = Copy.new([], :from => 'source', :to => ['t1', 't2'])
        UI.should_receive(:info).with("Guard::Copy will copy files from:")
        UI.should_receive(:info).with("  source")
        UI.should_receive(:info).with("to:")
        UI.should_receive(:info).with("  t1")
        UI.should_receive(:info).with("  t2")
        guard.start
      end

    end

    describe '#run_on_change' do

      it 'throws :task_has_failed when :to has no valid targets' do
        dir('source')
        guard = Copy.new([], :from => 'source', :to => 'invalid_target')
        UI.should_receive(:error).with("Guard::Copy - cannot copy, no valid :to directories")
        guard.start
        expect { guard.run_on_change([]) }.to throw_symbol(:task_has_failed)
      end

      it 'throws :task_has_failed when full target path does not exist' do
        dir('source/some/path/to/some')
        dir('target')
        guard = Copy.new([], :from => 'source', :to => 'target')
        UI.should_receive(:error).with('Guard::Copy - cannot copy, directory path does not exist:')
        UI.should_receive(:error).with('  target/some/path/to/some')
        guard.start
        expect {
          guard.run_on_change(['source/some/path/to/some/file'])
        }.to throw_symbol(:task_has_failed)
      end

      it 'copies files to a single target directory' do
        file('source/foo')
        dir('target')
        guard = Copy.new([], :from => 'source', :to => 'target')
        guard.start

        guard.run_on_change(['source/foo'])

        File.should be_file('target/foo')
      end

      it 'copies files to multiple target directories' do
        file('source/foo')
        dir('t1')
        dir('t2')
        guard = Copy.new([], :from => 'source', :to => ['t1', 't2'])
        guard.start

        guard.run_on_change(['source/foo'])

        File.should be_file('t1/foo')
        File.should be_file('t2/foo')
      end

      it 'copies files to globbed directories' do
        file('source/foo')
        dir('t1')
        dir('t2')
        guard = Copy.new([], :from => 'source', :to => 't*')
        guard.start

        guard.run_on_change(['source/foo'])

        File.should be_file('t1/foo')
        File.should be_file('t2/foo')
      end

      it 'copies files to newest glob directories' do
        file('source/foo')
        dir('target_old', 1978)
        dir('target_new', 2012)
        guard = Copy.new([], :from => 'source', :to => 'target*', :glob => :newest)
        guard.start

        guard.run_on_change(['source/foo'])

        File.should_not be_file('target_old/foo')
        File.should be_file('target_new/foo')
      end

    end

  end
end
