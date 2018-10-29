# frozen_string_literal: true

require 'optparse'
require 'swiftcore/tasks'
require 'ridgepole/executor/config'

module Ridgepole
  class Executor
    Task = Swiftcore::Tasks::Task
    # rubocop: disable Metrics/ClassLength
    # Handle the command line parsing.
    class Cli
      def initialize
        @config = Config.new
        @config[:adapter] = 'mysqlcli'
        @config[:migrator] = 'ptosc'
        @metaconfig = Config.new
        @metaconfig[:helptext] = []
      end

      def classname(klass)
        parts = klass.is_a?(Array) ? klass : klass.split(/::/)
        parts.inject(::Object) { |o, n| o.const_get n }
      end

      def installed_adapters
        `gem search -l ridgepole-executor-adapter`
          .split(/\n/)
          .select { |e| e =~ /ridgepole-executor-adapter-/ }
          .collect do |e|
            e =~ /ridgepole-executor-adapter-(\w+)/
            "    #{Regexp.last_match(1)}"
          end
          .join("\n")
      end

      def installed_migrators
        `gem search -l ridgepole-executor-migrator`
          .split(/\n/)
          .select { |e| e =~ /ridgepole-executor-migrator-/ }
          .collect do |e|
            e =~ /ridgepole-executor-migrator-(\w+)/
            "    #{Regexp.last_match(1)}"
          end
          .join("\n")
      end

      # rubocop: disable Metrics/MethodLength
      def _opt_help(opts, call_list)
        exe = File.basename($PROGRAM_NAME)
        text = <<~EHELP
          #{exe} SQL JSONCONFIG
          #{exe} [OPTIONS] -- SQL JSONCONFIG

          #{exe} takes a SQL statement and determines, based off of provided
          configuration and options, whether the SQL will cause a potentially service
          interrupting lock on the database, and thus whether it should run via a
          migration tool such as percona-online-schema-change or whether it can be sent
          directly to the database.

          The script is intended to be used as an external script with Ridgepole
          (https://github.com/winebarrel/ridgepole), and thus works with the Ridgepole
          CLI expectation, which is that the SQL to execute will be sent as ARGV1 and
          the Ridgepole configuration information will be sent as ARGV2. However, the
          script also supports a variety of other flags which can be used to tune
          behavior, to use the script with something other than Ridgepole, or to test
          behaviors.

          -?, -I, --help:
            Show this help.

          -a, --adapter:
            The database adapter to use.
            Installed database adapters:
            #{installed_adapters}

          -m, --migrator:
            The database migrator to use.
            Installed database migrators:
            #{installed_migrators}
        EHELP
        opts.on('-I', '-?', '--help') do
          @metaconfig[:helptext] << text
          call_list << Task.new(9999) do
            puts @metaconfig[:helptext]
            exit 0
          end
        end
      end
      # rubocop: enable Metrics/MethodLength

      def _opt_adapter(opts, call_list)
        opts.on('-a', '--adapter ADAPTER') do |adapter|
          @configuration[:adapter] = adapter
        end
        call_list << Task.new(0) do
          setup_plugin(
            :adapter,
            "ridgepole/executor/adapter/#{@configuration[:adapter]}"
          )
        end
      end

      def _opt_migrator(opts, call_list)
        opts.on('-m', '--migrator MIGRATOR') do |migrator|
          @configuration[:migrator] = migrator
        end
        call_list << Task.new(0) do
          setup_plugin(
            :migrator,
            "ridgepole/executor/migrator/#{@configuration[:migrator]}"
          )
        end
      end

      def _handle_leftover_args(options)
        leftover_argv = []

        begin
          options.parse!(ARGV)
        rescue OptionParser::InvalidOption => e
          e.recover ARGV
          leftover_argv << ARGV.shift
          leftover_argv << ARGV.shift if ARGV.any? && (ARGV.first[0..0] != '-')
          retry
        end

        ARGV.replace(leftover_argv) if leftover_argv.any?
      end

      def parse
        call_list = Swiftcore::Tasks::TaskList.new

        options = OptionParser.new do |opts|
          _opt_help(opts, call_list)
          _opt_adapter(opts, call_list)
          _opt_migrator(opts, call_list)
        end

        _handle_leftover_args(options)
        call_list
      end

      def setup_plugin(type, libname)
        require libname
        klass = classname(libname.split(%r{/}).collect(&:capitalize))
        @configuration[type] = klass
        return unless @configuration[type].respond_to? :parse

        @configuration[type]
          .parse(@configuration, @metaconfig)
      end

      def run
        parse.run
      end
    end
    # rubocop: enable Metrics/ClassLength
  end
end
