# frozen_string_literal: true

require "aggregate_assertions/assertion_aggregator"

module AggregateAssertions
  # Aggregate assertions for all test cases in a Minitest::Test class.
  module EachTest
    def capture_exceptions(&block)
      super do
        AssertionAggregator.wrap(&block)
      end
    end
  end
end
