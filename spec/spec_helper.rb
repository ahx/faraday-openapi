# frozen_string_literal: true

require 'faraday'
require 'webmock/rspec'
require_relative '../lib/faraday/openapi'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    Faraday::Openapi.registry.clear
  end

  config.order = :random
end
