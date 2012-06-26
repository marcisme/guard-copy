require 'spec_helper'

module Guard
  describe Copy::Target do

    describe '.initialize' do

      context 'with valid pattern' do

        let(:target) { Copy::Target.new('target') }

        it 'sets the pattern' do
          target.pattern.should == 'target'
        end

        it 'initializes paths' do
          target.paths.should == []
        end

        it 'sets default :glob option to :all' do
          target.options[:glob].should == :all
        end

      end

      context 'with nil' do
        it 'raises an error' do
          expect { Copy::Target.new(nil) }.to raise_error(ArgumentError, 'pattern cannot be nil')
        end
      end

      context 'with empty string' do
        it 'raises an error' do
          expect { Copy::Target.new('') }.to raise_error(ArgumentError, 'pattern cannot be empty')
        end
      end

    end

    describe '#resolve' do

      context 'with valid pattern' do

        let(:target) do
          dir('target')
          target = Copy::Target.new('target')
        end

        it 'returns true' do
          target.resolve.should be_true
        end

        it 'resets paths' do
          target.resolve
          target.resolve
          target.paths.size.should == 1
        end

      end

      context 'with invalid pattern' do

        let(:target) { Copy::Target.new('non_existent_target') }

        it 'returns false' do
          target.resolve.should be_false
        end

        it 'does not set any paths' do
          target.paths.size.should == 0
        end

      end

    end

    describe '#paths' do

      context 'with plain string pattern matching single directory' do
        it 'returns single path' do
          dir('target')
          target = Copy::Target.new('target')
          target.resolve
          target.paths.should == [ffs('target')]
        end
      end

      context 'with wildcard pattern matching multiple directories' do
        it 'returns multiple paths' do
          dir('t1')
          dir('t2')
          target = Copy::Target.new('t*')
          target.resolve
          target.paths.should == [ffs('t1'), ffs('t2')]
        end
      end

      context 'with wildcard pattern matching multiple directories and option :newest' do
        it 'returns single, newest path' do
          dir('target_old', 1978)
          dir('target_new', 2012)
          target = Copy::Target.new('t*', :glob => :newest)
          target.resolve
          target.paths.should == [ffs('target_new')]
        end
      end

    end

  end
end
