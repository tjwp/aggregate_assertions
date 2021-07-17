# frozen_string_literal: true

require_relative "error"

module AggregateAssertions
  # This class is used to aggregates the failures/errors for an aggregate block.
  class FailureGroup
    attr_reader :label, :location

    def initialize(location:, label: nil)
      @location = location
      @label = label
      @failures = []
      @other_errors = []
    end

    def add_error(error)
      if error.is_a?(Minitest::Assertion)
        @failures << error
      else
        @other_errors << error
      end
    end

    def error
      case @failures.size + @other_errors.size
      when 0
        nil
      when 1
        @failures.first || @other_errors.first
      else
        group_error
      end
    end

    def success?
      @failures.empty? && @other_errors.empty?
    end

    private

    def group_error
      Minitest::MultipleAssertionError.new(message_for_errors,
                                           location: location,
                                           result_label: result_label)
    end

    def message_for_errors
      errors = @failures + @other_errors
      "There were #{errors.size} errors#{group_label}:\n" +
        errors.map.with_index do |error, index|
          if error.is_a?(Minitest::Assertion)
            "    #{index + 1}) #{error.location}:\n#{indent(error.message)}\n"
          else
            "    #{index + 1}) #{error.class}: #{error.message}\n#{indent(error.backtrace.first)}\n"
          end
        end.join("\n")
    end

    def group_label
      label ? " in group #{label.inspect}" : ""
    end

    def result_label
      @other_errors.any? ? "Error" : nil
    end

    def indent(string, size: 6)
      prefix = (" " * size)
      string.split("\n").map { |str| "#{prefix}#{str}" }.join("\n")
    end
  end
end
