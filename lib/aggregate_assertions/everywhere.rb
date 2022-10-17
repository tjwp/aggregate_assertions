# frozen_string_literal: true

require_relative "aggregate_assertions/each_test"

Minitest::Test.prepend(AggregateAssertions::EachTest)
