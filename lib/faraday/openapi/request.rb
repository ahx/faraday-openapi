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

        rack_env = Rack::MockRequest.env_for(
          env.url,
          'CONTENT_TYPE' => env.request_headers['content-type'],
          method: env.method.to_s.upcase,
          input: StringIO.new(env.request_body || '')
        )
        env.request_headers.each do |key, value|
          rack_env["HTTP_#{key.upcase.tr('-', '_')}"] = value
        end
        Rack::Request.new(rack_env)
      end
    end
  end
end
