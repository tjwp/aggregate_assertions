# frozen_string_literal: true

require "test_helper"

class AggregateAssertionsTest < Minitest::Test
  def test_raises_a_single_error_for_multiple_assertions
    error = assert_raises(Minitest::MultipleAssertionError) do
      aggregate_assertions do
        assert_equal("red", "green")
        assert_equal(1, 0)
      end
    end

    assert_equal(Minitest::MultipleAssertionError, error.class)
    assert_includes(error.message, "There were 2 errors:")
  end

  def test_raises_original_error_for_single_assertion
    error = assert_raises(Minitest::Assertion) do
      aggregate_assertions do
        assert_equal("red", "green")
        assert(true)
      end
    end

    assert_equal(Minitest::Assertion, error.class)
    assert_includes(error.message, "Expected: \"red\"")
    assert_includes(error.message, "Actual: \"green\"")
  end

  def test_nested_aggregation
    error = assert_raises(Minitest::MultipleAssertionError) do
      aggregate_assertions("outer") do
        aggregate_assertions("inner") do
          assert(false)
          assert_equal(1, 0)
        end
        assert_nil("false")
      end
    end

    assert_equal(Minitest::MultipleAssertionError, error.class)
    assert_includes(error.message, "There were 2 errors in group \"outer\":")
    assert_includes(error.message, "There were 2 errors in group \"inner\":")
  end

  def test_non_assertion_error_raised
    error = assert_raises(Minitest::MultipleAssertionError) do
      aggregate_assertions do
        assert(false)
        raise StandardError, "boom!"
      end
    end

    assert_equal(Minitest::MultipleAssertionError, error.class)
    assert_includes(error.message, "There were 2 errors:")
    assert_includes(error.message, "2) StandardError: boom!")
    assert_equal(error.result_label, "Error")
  end

  def test_exception_is_not_rescued
    error = assert_raises(Exception) do
      aggregate_assertions do
        flunk
        raise Exception, "uncaught" # rubocop:disable Lint/RaiseException
      end
    end

    assert_equal(error.class, Exception)
    assert_equal(error.message, "uncaught")
  end
end
