# Changelog

## Unreleased

## 0.3.0

- Breaking change: Use `Faraday::Openapi.enabled=` instead of `Faraday::Openapi::Middleware.enabled=`
- Fix: Make `f.request :openapi` handle only request, not response validation
- Support passing a Hash to .register

## 0.2.0

- Add Faraday::Openapi.register to easily load, cache and reference OADs

## 0.1.1

Fix URL to homepage, changelog

## 0.1.0

Initial release.
