require 'spec_helper'

module Guard
  describe Copy::Target do

    describe '.resolve' do

      context 'with single directory' do
        it 'resolves a single target' do
          dir('target')
          Copy::Target.resolve('target', :all).should == ['target']
        end
      end

      context 'with multiple directories and :all option' do
        it 'resolves multiple targets' do
          dir('t1')
          dir('t2')
          Copy::Target.resolve(['t1', 't2'], :all).should == ['t1', 't2']
        end
      end

      context 'with glob and :all option' do
        it 'resolves multiple targets' do
          dir('t1')
          dir('t2')
          Copy::Target.resolve('t*', :all).should == ['t1', 't2']
        end
      end

      context 'with glob and :newest option' do
        it 'resolves newest target' do
          dir('target_old', 1978)
          dir('target_new', 2012)
          Copy::Target.resolve('t*', :newest).should == ['target_new']
        end
      end

    end

  end
end
