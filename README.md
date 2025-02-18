# Faraday Openapi

Validate requests/responses against OpenAPI API descriptions.

This middleware raises an error if the request or response does not match the given API description.
You can use this to test your client code or to make sure your mocks do match the actual implementation, described in the API description.

Note that the middleware currently deliberately ignores **unknown** responses with status codes 401 or higher because those usually don't come with a useful response body.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday-openapi'
```

And then execute:

```shell
bundle install
```

Or install it yourself as:

```shell
gem install faraday-openapi
```

## Usage

```ruby
require 'faraday/openapi'

conn = Faraday.new do |f|
  f.use :openapi, 'openapi/openapi.yaml'
end

# Or validate only requests
conn = Faraday.new do |f|
  f.request :openapi, 'openapi/openapi.yaml'
end

# Or validate only responses
conn = Faraday.new do |f|
  f.response :openapi, 'openapi/openapi.yaml'
end
```

You can disable the whole middleware globally:

```ruby
Faraday::Openapi::Middleware.default_options[:enabled] = false
```


## Development

After checking out the repo, run `bin/setup` to install dependencies.

Then, run `bin/test` to run the tests.

To install this gem onto your local machine, run `rake build`.

To release a new version, make a commit with a message such as "Bumped to 0.0.2" and then run `rake release`.
See how it works [here](https://bundler.io/guides/creating_gem.html#releasing-the-gem).

## Contributing

Bug reports and pull requests are welcome on [Codeberg](https://codeberg.org/ahx/faraday-openapi).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
