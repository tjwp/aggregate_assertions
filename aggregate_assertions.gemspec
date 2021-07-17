# frozen_string_literal: true

require_relative "lib/aggregate_assertions/version"

Gem::Specification.new do |spec|
  spec.name          = "aggregate_assertions"
  spec.version       = AggregateAssertions::VERSION
  spec.authors       = ["Tim Perkins"]
  spec.email         = ["tjwp@users.noreply.github.com"]

  spec.summary       = "Aggregate Minitest assertions"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/tjwp/aggregate_assertions"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/tjwp/aggregate_assertions/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("minitest", "~> 5.0")
end
