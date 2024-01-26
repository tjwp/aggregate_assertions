# aggregate_assertions

Aggregate assertions when testing using minitest. Similar to RSpec's [aggregate_failures](https://rspec.info/features/3-12/rspec-expectations/aggregating-failures/),
this gem enables the reporting failures from multiple assertions in a single test.

It is possible to use [rspec-expectations](https://github.com/rspec/rspec-expectations) with minitest, but the
`aggregate_assertions` gem adds this functionality with no dependencies beyond minitest itself when only assertions are
used.

Normally a test will stop at the first false assertion. Though we might attempt to write tests with a single assertion,
due to expensive setup it is often necessary, or more convenient, to make multiple assertions within a test.

Using the `aggregate_assertions` method from this gem with a block, all assertions from the block will be grouped and
reported as a single assertion at the completion of the block. The multiple assertion error that is reported contains
the messages from all the errors.

The `aggregate_assertions` implementation uses a thread-local variable, so assertions and other errors from different
threads will still cause a test to fail immediately.

## Installation

Add this line to the test group of your application's Gemfile:

```ruby
group "test" do
  gem "aggregate_assertions"
end
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install aggregate_assertions

## Usage

Use `aggregate_assertions` with a block in the body of a test. An optional label may be specified that will
be included in any aggregated error message:

```ruby
def test_response_example
  response = Struct.new(:status, :headers, :body).new(404, { "Content-Type" => "text/plain" }, "Not Found")

  aggregate_assertions("testing response") do
    assert_equal(200, response.status)
    assert_equal("application/json", response.headers["Content-Type"])
    assert_equal('{"message":"Success"}', response.body)
  end
end
```
The failure from this test produces the error:
```
Failure:
ExampleTest#test_response_example [test/test_example.rb:5]:
There were 3 errors in group "testing response":
    1) /Users/tjwp/git/aggregate_assertions/test/aggregate_assertions_test.rb:8:
      Expected: 200
        Actual: 404

    2) /Users/tjwp/git/aggregate_assertions/test/aggregate_assertions_test.rb:9:
      Expected: "application/json"
        Actual: "text/plain"

    3) /Users/tjwp/git/aggregate_assertions/test/aggregate_assertions_test.rb:10:
      Expected: "{\"message\":\"Success\"}"
        Actual: "Not Found"
```

### Experimental: Enable for all tests

All tests in a class or an entire test suite can be implicitly wrapped
with `aggregate_assertions`.

To enable for all tests in a class include the module `AggregateAssertions::EachTest`:

```ruby
class MyTest < Minitest::Test
  include AggregateAssertions::EachTest

  def test_both_errors_reported
    # both assertions are reported without needing an explicit aggregate_assertions block
    assert false, "first error"
    assert false, "second error"
  end
end
```

To enable for all tests in a test suite require `aggregate_assertions/everywhere` from your `test_helper.rb` file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To check code style, run `bundle exec rubocop`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tjwp/aggregate_assertions.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
