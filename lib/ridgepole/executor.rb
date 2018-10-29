# frozen_string_literal: true

require 'ridgepole/executor/cli'
require 'ridgepole/executor/version'

module Ridgepole
  # This is a utility, intended to be used with Ridgepole, that will execute
  # ALTER statements with a nonblocking migration tool such as
  # percona-online-schema-change, while vectoring everything that doesn't need
  # special handling directly to the database client.
  class Executor
    def self.run
      executor = Executor.new
      executor.run
    end

    def initialize
      @cli = Cli.new
    end

    def run
      @cli.run
    end
  end
end
