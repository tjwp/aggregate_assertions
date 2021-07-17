# frozen_string_literal: true

require "minitest"
require_relative "aggregate_assertions/version"
require_relative "aggregate_assertions/assertion_aggregator"

module AggregateAssertions
  # Contains patches to the Minitest::Test class
  module TestPatch
    def assert(test, msg = nil)
      super
    rescue Minitest::Assertion, StandardError => ex
      raise unless AssertionAggregator.active?

      AssertionAggregator.add_error(ex)
    end

    def aggregate_assertions(label = nil)
      flunk "aggregate_assertions requires a block" unless block_given?

      AssertionAggregator.open_failure_group(label)

      begin
        yield
      rescue Minitest::Assertion, StandardError => ex
        AssertionAggregator.add_error(ex)
      ensure
        failure_group = AssertionAggregator.close_failure_group
      end

      return if failure_group.success?

      raise failure_group.error unless AssertionAggregator.active?

      AssertionAggregator.add_error(failure_group.error)
    end
  end
end

Minitest::Test.prepend(AggregateAssertions::TestPatch)
