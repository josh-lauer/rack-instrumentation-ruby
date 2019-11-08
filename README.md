# rack-instrumentation

Open Tracing instrumentation for [rack](https://github.com/rack/rack). By default it starts a new span for every request and follows the open tracing tagging [semantic conventions](https://opentracing.io/specification/conventions). This is inspired by the [rack-tracer](https://github.com/opentracing-contrib/ruby-rack-tracer) gem, and sections of the code here are taken from there.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rack-instrumentation"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-instrumentation

## Usage

Require the gem (Note: this won't automatically instrument rack)
```ruby
require "rack/instrumentation"
```

If you have set up `OpenTracing.global_tracer` you can turn on spans for all requests in your `config.ru` thusly:
```ruby
use Rack::OpenTracing::Tracer
```

Similarly, this works for rails applications:
```ruby
Rails.application.configure do
  config.middleware.use Rack::Instrumentation::Tracer
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-instrumentation-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
