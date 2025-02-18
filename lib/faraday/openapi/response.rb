# frozen_string_literal: true

require 'rack'

module Faraday
  module Openapi
    # @visibility private
    # Build a Rack::Response from a Faraday::Env
    module Response
      def self.from_env(env)
        status = env.status
        headers = env.response_headers
        body = [env.response_body]

        Rack::Response.new(body, status, headers)
      end
    end
  end
end
