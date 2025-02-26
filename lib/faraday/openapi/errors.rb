# frozen_string_literal: true

module Faraday
  module Openapi
    # Base class for all errors
    class Error < StandardError; end

    # Raised if request does not match API description or is unknown
    class RequestInvalidError < Error; end

    # Raised if response does not match API description or is unknown
    class ResponseInvalidError < Error; end

    class AlreadyRegisteredError < Error; end
    class NotRegisteredError < Error; end
  end
end
