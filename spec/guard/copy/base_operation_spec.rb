require 'spec_helper'
require 'guard/copy/base_operation'
require 'guard/copy/error'

module Guard
  class Copy
    describe BaseOperation do

      describe '#with_target_path' do

        context 'when not overriden' do

          class TestOperation < BaseOperation
          end

          it 'raises an error' do
            expect do
              TestOperation.new({}).with_target_path(nil, nil)
            end.to raise_error(Error, 'override Guard::Copy::TestOperation#with_target_path')
          end

        end

      end

    end
  end
end

