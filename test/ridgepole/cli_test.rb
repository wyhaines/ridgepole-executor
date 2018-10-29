# frozen_string_literal: true

require 'test_helper'

# rubocop: disable Style/ClassAndModuleChildren
# Test the Ridgepole Cli class.
class Ridgepole::ExecutorCliTest < Minitest::Test
  def test_cli
    cli = Ridgepole::Executor::Cli.new
  end
end
