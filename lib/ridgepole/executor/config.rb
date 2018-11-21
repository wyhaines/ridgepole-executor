# frozen_string_literal: true

require 'json'

module Ridgepole
  class Executor
    # Parse and encapsulate the configuration that may be provided.
    class Config
      attr_reader :config

      def initialize(json = '{}')
        @config = {}
        parse(json)
      end

      def parse(json = '{}')
        json = '{}' if json.to_s.empty?
        @config = @config.merge(JSON.parse(json))
      end

      def [](val)
        @config[val.to_sym] || @config[val.to_s]
      end

      def []=(key, val)
        @config[key] = val
      end

      def merge(other)
        @config.merge(other)
      end

      def merge!(other)
        @config.merge!(other)
      end

      def to_hash
        @config
      end

      def method_missing(meth, *args, &block)
        if @config.key?(meth) || @config.key?(meth.to_s)
          @config[meth] || @config[meth.to_s]
        else
          super
        end
      end

      def respond_to_missing?(meth, *args)
        @config.key?(meth) || @config.key?(meth.to_s) || super
      end
    end
  end
end
