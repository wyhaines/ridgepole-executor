# frozen_string_literal: true

require 'test_helper'

# rubocop: disable Style/ClassAndModuleChildren
# Test the Ridgepole Configuration class.
class Ridgepole::ExecutorConfigTest < Minitest::Test
  CANNED_JSON_CONFIG = <<~EJSON
    {"adapter":"mysql2",
     "encoding":"utf8",
     "database":"testdb",
     "username":"root",
     "max_load":"Threads_running=90"}
  EJSON

  EMPTY_JSON_CONFIG = ''

  def test_handles_empty_config
    config = Ridgepole::Executor::Config.new(EMPTY_JSON_CONFIG)
    assert config.config.empty?
  end

  def test_handles_normal_config
    config = Ridgepole::Executor::Config.new(CANNED_JSON_CONFIG)
    check_length(5, config)
    check_respond_to(config)
    check_standard(config)
    check_extra(config)
  end

  def check_length(len, config)
    assert config.config.length == len
  end

  def check_respond_to(config)
    assert config.respond_to?(:database)
    assert !config.respond_to?(:nothere)
  end

  def check_standard(config)
    assert config['adapter'] == 'mysql2'
    assert config['max_load'] == 'Threads_running=90'
    assert config.username == 'root'
  end

  def check_extra(config)
    config[:extra] = 'extra'
    assert config.extra == 'extra'
  end

  def test_parse_after_creation
    config = Ridgepole::Executor::Config.new('{"after":"true"}')
    config.parse(CANNED_JSON_CONFIG)
    check_length(6, config)
    check_respond_to(config)
    check_standard(config)
    check_extra(config)
  end
end
# rubocop: enable Style/ClassAndModuleChildren
