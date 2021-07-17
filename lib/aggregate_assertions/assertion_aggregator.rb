# frozen_string_literal: true

require_relative("error")
require_relative("failure_group")

module AggregateAssertions
  # Main entry-point for the interacting with the state of aggregation.
  module AssertionAggregator
    class << self
      def active?
        !store.nil? && !store.empty?
      end

      def add_error(ex)
        store.last.add_error(ex)
      end

      def open_failure_group(label = nil)
        initialize_store << FailureGroup.new(label: label, location: location)
      end

      def close_failure_group
        store.pop
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