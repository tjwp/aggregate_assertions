# frozen_string_literal: true

module Minitest
  # Error raised when multiple assertions are grouped together.
  class MultipleAssertionError < Minitest::Assertion
    attr_reader :location

    def initialize(msg = nil, location: nil, result_label: nil)
      super(msg)
      @location = location
      @result_label = result_label
    end

    def result_label
      @result_label || super
    end
  end
end
