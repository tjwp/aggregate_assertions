# frozen_string_literal: true

require "minitest"
require_relative "aggregate_assertions/version"
require_relative "aggregate_assertions/each_test"
require_relative "aggregate_assertions/assertion_aggregator"

module AggregateAssertions
  # Contains patches to the Minitest::Test class
  module TestPatch
    def assert(test, msg = nil)
      super
    rescue Minitest::Assertion, StandardError => e
      raise unless AssertionAggregator.active?

      AssertionAggregator.add_error(e)
    end

    def aggregate_assertions(label = nil, &block)
      flunk "aggregate_assertions requires a block" unless block_given?

      AssertionAggregator.wrap(label, &block)
    end
  end
end

Minitest::Test.prepend(AggregateAssertions::TestPatch)
