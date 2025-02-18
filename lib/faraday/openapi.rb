# frozen_string_literal: true

require_relative 'openapi/errors'
require_relative 'openapi/middleware'
require_relative 'openapi/version'

module Faraday
  # This will be your middleware main module, though the actual middleware implementation will go
  # into Faraday::Openapi::Middleware for the correct namespacing.
  module Openapi
    # Faraday allows you to register your middleware for easier configuration.
    # This step is totally optional, but it basically allows users to use a
    # custom symbol (in this case, `:openapi`), to use your middleware in their connections.
    # After calling this line, the following are both valid ways to set the middleware in a connection:
    # * conn.use Faraday::Openapi::Middleware
    # * conn.use :openapi
    # Without this line, only the former method is valid.
    Faraday::Middleware.register_middleware(openapi: Faraday::Openapi::Middleware)
    Faraday::Request.register_middleware(openapi: Faraday::Openapi::Middleware)
    Faraday::Response.register_middleware(openapi: Faraday::Openapi::Middleware)

    # Alternatively, you can register your middleware under Faraday::Request or Faraday::Response.
    # This will allow to load your middleware using the `request` or `response` methods respectively.
    #
    # Load middleware with conn.request :openapi
    # Faraday::Request.register_middleware(openapi: Faraday::Openapi::Middleware)
    #
    # Load middleware with conn.response :openapi
    # Faraday::Response.register_middleware(openapi: Faraday::Openapi::Middleware)
  end
end
