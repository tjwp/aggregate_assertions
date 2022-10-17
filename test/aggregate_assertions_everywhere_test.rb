# frozen_string_literal: true

require "test_helper"
require "minitest/metametameta"

class AggregateAssertionsEverywhereTest < MetaMetaMetaTestCase
  def normalize_output(output)
    super

    output.gsub!(/^(\s+\d+\) )(?:[A-Za-z]:)?[^:]+:\d+:/, '\1FILE:LINE:')

    output
  end

  def test_raises_a_single_error_for_multiple_assertions
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest

      def test_two_assertions
        assert_equal("red", "green")
        assert_equal(1, 0)
      end
    end

    expected = clean <<-REPORT
      F

      Finished in 0.00

        1) Failure:
      FakeNamedTestXX#test_two_assertions [FILE:LINE]:
      There were 2 errors:
          1) FILE:LINE:
            Expected: \"red\"
              Actual: \"green\"

          2) FILE:LINE:
            Expected: 1
              Actual: 0


      1 runs, 2 assertions, 0 failures, 0 errors, 0 skips
    REPORT

    assert_report expected
  end

  def test_raises_original_error_for_single_assertion
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest
      def test_two_assertions
        assert_equal("red", "green")
        assert(true)
      end
    end

    expected = clean <<-REPORT
      F

      Finished in 0.00

        1) Failure:
      FakeNamedTestXX#test_two_assertions [FILE:LINE]:
      Expected: \"red\"
        Actual: \"green\"

      1 runs, 2 assertions, 1 failures, 0 errors, 0 skips
    REPORT

    assert_report expected
  end

  def test_nested_aggregation
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest
      def test_uses_aggregate_assertions
        aggregate_assertions("inner") do
          assert(false)
          assert_equal(1, 0)
        end
        assert_nil("false")
      end
    end

    expected = clean <<-REPORT
      F

      Finished in 0.00

        1) Failure:
      FakeNamedTestXX#test_uses_aggregate_assertions [FILE:LINE]:
      There were 2 errors:
          1) FILE:LINE:
            There were 2 errors in group \"inner\":
                1) FILE:LINE:
                  Expected false to be truthy.

                2) FILE:LINE:
                  Expected: 1
                    Actual: 0

          2) FILE:LINE:
            Expected \"false\" to be nil.


      1 runs, 3 assertions, 0 failures, 0 errors, 0 skips
    REPORT

    assert_report expected
  end

  def test_non_assertion_error_raised
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest
      def test_non_assertion
        assert(false)
        raise StandardError, "boom!"
      end
    end

    expected = clean <<-REPORT
      E

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_non_assertion [FILE:LINE]:
      There were 2 errors:
          1) FILE:LINE:
            Expected false to be truthy.

          2) StandardError: boom!
            FILE:LINE:in `test_non_assertion'


      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    REPORT

    assert_report expected
  end

  def test_exception_is_not_rescued
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest
      def test_exception
        flunk
        raise Exception, "uncaught" # rubocop:disable Lint/RaiseException
      end
    end

    expected = clean <<-REPORT
      E

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_exception:
      Exception: uncaught
          FILE:LINE:in `test_exception'

      1 runs, 1 assertions, 0 failures, 1 errors, 0 skips
    REPORT

    assert_report expected
  end

  def test_setup_errors_are_not_aggregated
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest
      def setup
        raise "once"
        raise "twice" # rubocop:disable Lint/UnreachableCode
      end

      def test_nothing; end
    end

    expected = clean <<-REPORT
      E

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_nothing:
      RuntimeError: once
          FILE:LINE:in `setup'

      1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
    REPORT

    assert_report expected
  end

  def test_setup_assertions_are_aggregated
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest
      def setup
        assert false, "an assertion"
        raise "an error"
      end

      def test_nothing; end
    end

    expected = clean <<-REPORT
      E

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_nothing [FILE:LINE]:
      There were 2 errors:
          1) FILE:LINE:
            an assertion

          2) RuntimeError: an error
            FILE:LINE:in `setup'


      1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
    REPORT

    assert_report expected
  end

  def test_teardown_errors_are_not_aggregated
    @tu = Class.new(FakeNamedTest) do
      include AggregateAssertions::EachTest
      def teardown
        raise "once"
        raise "twice" # rubocop:disable Lint/UnreachableCode
      end

      def test_nothing; end
    end

    expected = clean <<-REPORT
      E

      Finished in 0.00

        1) Error:
      FakeNamedTestXX#test_nothing:
      RuntimeError: once
          FILE:LINE:in `teardown'

      1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
    REPORT

    assert_report expected
  end
end
