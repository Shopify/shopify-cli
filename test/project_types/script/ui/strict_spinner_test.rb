# frozen_string_literal: true

require 'project_types/script/test_helper'

describe Script::UI::StrictSpinner do
  describe '.spin' do
    let(:title) { 'title' }

    describe 'when an error is thrown in the block' do
      it 'should abort' do
        assert_raises(StandardError, 'some err') do
          capture_io { Script::UI::StrictSpinner.spin(title, auto_debrief: false) { raise(StandardError, 'some err') } }
        end
      end
    end

    describe 'when the block runs successfully' do
      it 'should do nothing' do
        assert_nothing_raised { capture_io { Script::UI::StrictSpinner.spin(title, auto_debrief: false) { true } } }
      end
    end
  end
end
