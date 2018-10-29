# frozen_string_literal: true

require 'test_helper'

# rubocop: disable Style/ClassAndModuleChildren
# Test the Executor
class Ridgepole::ExecutorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ridgepole::Executor::VERSION
  end

  def test_it_does_something_useful
    assert true
  end
end
# rubocop: enable Style/ClassAndModuleChildren
