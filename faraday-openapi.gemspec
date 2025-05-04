# frozen_string_literal: true

require_relative 'lib/faraday/openapi/version'

Gem::Specification.new do |spec|
  spec.name = 'faraday-openapi'
  spec.version = Faraday::Openapi::VERSION
  spec.authors = ['Andreas Haller']
  spec.email = ['ahx@posteo.de']

  spec.summary = 'Validate requests/responses against OpenAPI API descriptions'
  spec.description = <<~DESC
    Validate requests/responses against OpenAPI API descriptions.
  DESC
  spec.license = 'MIT'

  forge_uri = "https://codeberg.org/ahx/#{spec.name}"

  spec.homepage = forge_uri

  spec.metadata = {
    'bug_tracker_uri' => "#{forge_uri}/issues",
    'changelog_uri' => "#{forge_uri}/src/branch/main/CHANGELOG.md",
    'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => forge_uri
  }

  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE.md', 'CHANGELOG.md']

  spec.required_ruby_version = '>= 3.2', '< 4'

  spec.add_dependency 'faraday', '>= 2.9', '< 3'
  spec.add_dependency 'openapi_first', '>= 2.7', '< 3'
  spec.add_dependency 'rack', '>= 2.2', '< 4.0'
end
