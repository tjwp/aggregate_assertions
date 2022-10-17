# frozen_string_literal: true

require "minitest"
require_relative "error"
require_relative "failure_group"

module AggregateAssertions
  # Main entry-point for the interacting with the state of aggregation.
  module AssertionAggregator
    class << self
      def active?
        !store.nil? && !store.empty?
      end

      def add_error(error)
        store.last.add_error(error)
      end

      def open_failure_group(label = nil)
        initialize_store << FailureGroup.new(label: label, location: location)
      end

      def close_failure_group
        store.pop
      end

      def wrap(label = nil)
        AssertionAggregator.open_failure_group(label)

        begin
          yield
        rescue Minitest::Assertion, StandardError => e
          AssertionAggregator.add_error(e)
        ensure
          failure_group = AssertionAggregator.close_failure_group
        end

        return if failure_group.success?

        raise failure_group.error unless AssertionAggregator.active?

        AssertionAggregator.add_error(failure_group.error)
      end

      private

      def store
        Thread.current[:__mt_aggregate]
      end

      def initialize_store
        Thread.current[:__mt_aggregate] ||= []
      end

      def location
        caller(3, 1).first.sub(/:in .*$/, "")
      end
    end
  end
end
