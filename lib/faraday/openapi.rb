# frozen_string_literal: true

require 'openapi_first'
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
    Faraday::Middleware.register_middleware(openapi: Faraday::Openapi::Middleware)
    Faraday::Request.register_middleware(openapi: Faraday::Openapi::Middleware)
    Faraday::Response.register_middleware(openapi: Faraday::Openapi::Middleware)

    @registry = {}

    class << self
      attr_reader :registry
    end

    def self.register(filepath, as: :default)
      raise AlreadyRegisteredError, "API description #{as} is already registered" if registry.key?(as)

      oad = filepath.is_a?(Hash) ? OpenapiFirst.parse(filepath) : OpenapiFirst.load(filepath)
      registry[as] = oad
    end

    def self.[](key)
      registry.fetch(key) do
        message = if registry.empty?
                    'No API descriptions have been registered. Please register your API description via ' \
                      "Faraday::Openapi.register('myopenapi.yaml')"
                  else
                    "API description #{key.inspect} was not found. Please register your API description via " \
                      "Faraday::Openapi.register('myopenapi.yaml'#{key == :default ? '' : ", as: #{key.inspect}"})"
                  end
        raise NotRegisteredError, message
      end
    end
  end
end
