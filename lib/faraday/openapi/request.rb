# frozen_string_literal: true

require 'rack'

module Faraday
  module Openapi
    # @visibility private
    # Build a Rack::Request from a Faraday::Env
    module Request
      def self.from_env(env) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        if env.request_body.is_a?(Hash)
          raise Error,
                'env.body is a Hash. You probably want to convert the request body ' \
                'to JSON before calling the Faraday openapi middleware.'
        end

        rack_env = {
          'REQUEST_METHOD' => env.method.to_s.upcase,
          'PATH_INFO' => env.url.path,
          'QUERY_STRING' => env.url.query || '',
          'SERVER_NAME' => env.url.host,
          'SERVER_PORT' => env.url.port.to_s,
          'rack.url_scheme' => env.url.scheme,
          'rack.input' => StringIO.new(env.request_body || '')
        }

        env.request_headers.each do |key, value|
          rack_env["HTTP_#{key.upcase.tr('-', '_')}"] = value
        end

        Rack::Request.new(rack_env)
      end
    end
  end
end
