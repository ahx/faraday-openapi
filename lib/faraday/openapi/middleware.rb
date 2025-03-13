# frozen_string_literal: true

require 'faraday'
require 'openapi_first'
require_relative 'request'
require_relative 'response'

module Faraday
  module Openapi
    # Methods for all middlewares
    module Base
      def initialize(app, path = :default)
        super(app)
        return unless Openapi.enabled

        @oad = path.is_a?(Symbol) ? Faraday::Openapi[path] : OpenapiFirst.load(path)
      end

      def call(env)
        return app.call(env) unless Openapi.enabled

        super
      end
    end

    # on_request method to handle request validation
    module RequestValidation
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
    end

    # on_complete method to handle response validation
    module ResponseValidation
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

    class Middleware < Faraday::Middleware
      include Base
      include RequestValidation
      include ResponseValidation
    end

    class RequestMiddleware < Faraday::Middleware
      include Base
      include RequestValidation
    end

    class ResponseMiddleware < Faraday::Middleware
      include Base
      include ResponseValidation
    end
  end
end
