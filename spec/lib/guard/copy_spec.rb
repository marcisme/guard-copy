require 'spec_helper'
require 'guard/copy'
require 'fileutils'

module Guard
  describe Copy do

    describe '#initialize' do

      it 'sets a single target' do
        guard = Copy.new([], :to => 'target')
        guard.targets.should == ['target']
      end

      it 'sets multiple targets' do
        guard = Copy.new([], :to => ['t1', 't2'])
        guard.targets.should == ['t1', 't2']
      end

      it 'preserves globs' do
        guard = Copy.new([], :to => ['t*'])
        guard.targets.should == ['t*']
      end

      it 'freezes targets array' do
        guard = Copy.new([], :to => 'target')
        guard.targets.should be_frozen
      end

      it 'creates a single watcher with :from' do
        guard = Copy.new([], :from => 'source')
        guard.watchers.count.should == 1
        guard.watchers.first.pattern == %r{source/.*}
      end

    end

    describe '#start' do

      it 'throws :task_has_failed when :from is not provided' do
        guard = Copy.new
        expect { guard.start }.to throw_symbol(
          :task_has_failed,
          'Guard::Copy requires a valid source directory in :from'
        )
      end

      it 'displays :from and :to directories when single target' do
        guard = Copy.new([], :from => 'source', :to => 'target')
        UI.expects(:info).with("Guard::Copy will copy files from 'source' to:")
        UI.expects(:info).with("  target")
        guard.start
      end

      it 'displays :from and :to directories when multiple targets' do
        guard = Copy.new([], :from => 'source', :to => ['t1', 't2'])
        UI.expects(:info).with("Guard::Copy will copy files from 'source' to:")
        UI.expects(:info).with("  t1")
        UI.expects(:info).with("  t2")
        guard.start
      end

    end

    describe '#run_on_change' do

      it 'copies files to a single target directory' do
        path('source/foo')
        dir('target')
        guard = Copy.new([], :from => 'source', :to => 'target')

        guard.run_on_change(['source/foo'])

        File.should be_file('target/foo')
      end

      it 'copies files to multiple target directories' do
        path('source/foo')
        dir('t1')
        dir('t2')
        guard = Copy.new([], :from => 'source', :to => ['t1', 't2'])

        guard.run_on_change(['source/foo'])

        File.should be_file('t1/foo')
        File.should be_file('t2/foo')
      end

      it 'copies files to globbed directories' do
        path('source/foo')
        dir('t1')
        dir('t2')
        guard = Copy.new([], :from => 'source', :to => 't*')

        guard.run_on_change(['source/foo'])

        File.should be_file('t1/foo')
        File.should be_file('t2/foo')
      end

      it 'copies files to newest glob directories' do
        path('source/foo')
        dir('target_old', 1978)
        dir('target_new', 2012)
        guard = Copy.new([], :from => 'source', :to => 'target*', :glob => :newest)

        guard.run_on_change(['source/foo'])

        File.should_not be_file('target_old/foo')
        File.should be_file('target_new/foo')
      end

    end

  end
end
