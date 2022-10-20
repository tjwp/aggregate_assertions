# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift File.join(Gem.loaded_specs["minitest"].full_gem_path, "test")

require "minitest/autorun"
require "aggregate_assertions"
