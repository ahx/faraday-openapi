# frozen_string_literal: true

require 'faraday'
require 'openapi_first'
require_relative 'request'
require_relative 'response'

module Faraday
  module Openapi
    # This class provides the main implementation for your middleware.
    # Your middleware can implement any of the following methods:
    # * on_request - called when the request is being prepared
    # * on_complete - called when the response is being processed
    #
    # Optionally, you can also override the following methods from Faraday::Middleware
    # * initialize(app, options = {}) - the initializer method
    # * call(env) - the main middleware invocation method.
    #   This already calls on_request and on_complete, so you normally don't need to override it.
    #   You may need to in case you need to "wrap" the request or need more control
    #   (see "retry" middleware: https://github.com/lostisland/faraday-retry/blob/41b7ea27e30d99ebfed958abfa11d12b01f6b6d1/lib/faraday/retry/middleware.rb#L147).
    #   IMPORTANT: Remember to call `@app.call(env)` or `super` to not interrupt the middleware chain!
    class Middleware < Faraday::Middleware
      DEFAULT_OPTIONS = { enabled: true }.freeze

      def self.enabled=(bool)
        Faraday::Openapi::Middleware.default_options[:enabled] = bool
      end

      def initialize(app, path = :default)
        super(app)
        @enabled = options.fetch(:enabled, true)
        return unless @enabled

        @oad = path.is_a?(Symbol) ? Faraday::Openapi[path] : OpenapiFirst.load(path)
      end

      def call(env)
        return app.call(env) unless @enabled

        super
      end

      # This method will be called when the request is being prepared.
      # You can alter it as you like, accessing things like request_body, request_headers, and more.
      # Refer to Faraday::Env for a list of accessible fields:
      # https://github.com/lostisland/faraday/blob/main/lib/faraday/options/env.rb
      #
      # @param env [Faraday::Env] the environment of the request being processed
      def on_request(env)
        request = Request.from_env(env)
        @oad.validate_request(request, raise_error: true)
      rescue OpenapiFirst::RequestInvalidError => e
        raise RequestInvalidError, e.message
      end

      # This method will be called when the response is being processed.
      # You can alter it as you like, accessing things like response_body, response_headers, and more.
      # Refer to Faraday::Env for a list of accessible fields:
      # https://github.com/lostisland/faraday/blob/main/lib/faraday/options/env.rb
      #
      # @param env [Faraday::Env] the environment of the response being processed.
      def on_complete(env)
        request = Request.from_env(env)
        response = Response.from_env(env)
        @oad.validate_response(request, response, raise_error: true)
      rescue OpenapiFirst::ResponseInvalidError, OpenapiFirst::ResponseNotFoundError => e
        return if e.is_a?(OpenapiFirst::ResponseNotFoundError) && (response.status >= 401)

        raise ResponseInvalidError, e.message
      end
    end
  end
end
