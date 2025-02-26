# frozen_string_literal: true

require 'json'

RSpec.describe Faraday::Openapi::Middleware do
  subject(:connection) do
    Faraday.new(url: 'http://dice.local') do |f|
      f.response :json
      f.use :openapi, 'spec/data/dice.yaml'
    end
  end

  describe 'validate request' do
    before do
      stub_request(:post, 'http://dice.local/roll?sides=1,2')
        .to_return(
          headers: { 'content-type' => 'application/json' },
          body: JSON.generate(5),
          status: 200
        )
    end

    context 'with a valid request' do
      it 'does nothing' do
        response = connection.post('/roll') do |req|
          req.params['sides'] = '1,2'
          req.headers['Content-Type'] = 'application/json'
          req.headers['cheat-result'] = '5'
          req.body = JSON.generate({ dice: %w[one two] })
        end
        expect(response.body).to eq(5)
      end

      it 'does not support a Hash body' do
        expect do
          connection.post('/roll') do |req|
            req.params['sides'] = '1,2'
            req.headers['Content-Type'] = 'application/json'
            req.headers['cheat-result'] = '5'
            req.body = { dice: %w[one two] }
          end
        end.to raise_error Faraday::Openapi::Error
      end
    end

    context 'with an unknown path' do
      before do
        stub_request(:post, 'http://dice.local/unknown')
          .to_return(
            status: 400
          )
      end

      it 'raises an error' do
        expect do
          connection.post('/unknown')
        end.to raise_error(Faraday::Openapi::RequestInvalidError, 'Request path is not defined.')
      end
    end

    context 'when disabled globally' do
      before do
        described_class.default_options[:enabled] = false

        stub_request(:post, 'http://dice.local/unknown')
          .to_return(
            status: 404
          )
      end

      after do
        described_class.default_options[:enabled] = true
      end

      it 'does nothing' do
        expect(connection.post('/unknown').status).to eq(404)
      end
    end

    context 'with a invalid request body' do
      it 'raises an error' do
        expect do
          connection.post('/roll') do |req|
            req.params['sides'] = '1,2'
            req.headers['Content-Type'] = 'application/xml'
            req.headers['cheat-result'] = '5'
            req.body = JSON.generate({ dice: { 1 => 2 } })
          end
        end.to raise_error(Faraday::Openapi::RequestInvalidError, 'Request body invalid: value at `/dice` is not an array')
      end
    end

    context 'with an invalid query parameter' do
      before do
        stub_request(:post, 'http://dice.local/roll?sides=0')
          .to_return(
            status: 400
          )
      end

      it 'raises an error' do
        expect do
          connection.post('/roll') do |req|
            req.params['sides'] = '0'
            req.headers['Content-Type'] = 'application/xml'
            req.headers['cheat-result'] = '5'
            req.body = JSON.generate({ dice: %w[one two] })
          end
        end.to raise_error(Faraday::Openapi::RequestInvalidError, 'Query parameter is invalid: number at `/sides/0` is less than: 1')
      end
    end
  end

  describe 'validate response' do
    context 'with a valid response' do
      before do
        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/json' },
            body: JSON.generate(5),
            status: 200
          )
      end

      it 'does nothing' do
        response = connection.post('/roll')
        expect(response.status).to eq(200)
      end
    end

    context 'when disabled globally' do
      before do
        described_class.default_options[:enabled] = false

        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/json' },
            body: JSON.generate(5),
            status: 201
          )
      end

      after do
        described_class.default_options[:enabled] = true
      end

      it 'does nothing' do
        expect(connection.post('/roll').status).to eq(201)
      end
    end

    context 'with an unknown success response status' do
      before do
        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/json' },
            body: JSON.generate(5),
            status: 201
          )
      end

      it 'raises an error' do
        expect { connection.post('/roll') }.to raise_error Faraday::Openapi::ResponseInvalidError
      end
    end

    context 'with an unknown 5XX response status' do
      before do
        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/json' },
            body: JSON.generate(5),
            status: 500
          )
      end

      it 'does nothing' do
        expect(connection.post('/roll').status).to eq(500)
      end
    end

    context 'with an unknown >= 401 response status' do
      before do
        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/json' },
            body: JSON.generate(5),
            status: 401
          )
      end

      it 'does nothing' do
        expect(connection.post('/roll').status).to eq(401)
      end
    end

    context 'with an unknown 400 response status' do
      before do
        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/json' },
            body: JSON.generate(5),
            status: 400
          )
      end

      it 'raises an error' do
        expect do
          connection.post('/roll')
        end.to raise_error Faraday::Openapi::ResponseInvalidError
      end
    end

    context 'with an invalid response header value' do
      before do
        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/xml' },
            body: JSON.generate(5),
            status: 200
          )
      end

      it 'raises an error' do
        expect { connection.post('/roll') }.to raise_error Faraday::Openapi::ResponseInvalidError
      end
    end

    context 'with a invalid response body' do
      before do
        stub_request(:post, 'http://dice.local/roll')
          .to_return(
            headers: { 'content-type' => 'application/json' },
            body: JSON.generate({ bar: 'baz' }),
            status: 200
          )
      end

      it 'raises an error' do
        expect { connection.post('/roll') }.to raise_error Faraday::Openapi::ResponseInvalidError
      end
    end
  end

  context 'when named API was not found' do
    it 'raises an error' do
      expect do
        connection = Faraday.new(url: 'http://dice.local') do |f|
          f.use :openapi, :unknown
        end
        connection.post('roll')
      end.to raise_error Faraday::Openapi::NotRegisteredError
    end
  end

  context 'without a specified name (:default)' do
    subject(:connection) do
      Faraday.new(url: 'http://dice.local') do |f|
        f.response :json
        f.use :openapi
      end
    end

    before do
      Faraday::Openapi.register('spec/data/dice.yaml')
    end

    it 'validates against that API' do
      stub_request(:post, 'http://dice.local/roll')
        .to_return(
          headers: { 'content-type' => 'application/json' },
          body: JSON.generate({ bar: 'baz' }),
          status: 200
        )

      expect { connection.post('/roll') }.to raise_error Faraday::Openapi::ResponseInvalidError
    end
  end

  context 'with a named API' do
    subject(:connection) do
      Faraday.new(url: 'http://dice.local') do |f|
        f.response :json
        f.use :openapi, :dice_api
      end
    end

    before do
      Faraday::Openapi.register('spec/data/dice.yaml', as: :dice_api)
    end

    it 'validates against that API' do
      stub_request(:post, 'http://dice.local/roll')
        .to_return(
          headers: { 'content-type' => 'application/json' },
          body: JSON.generate({ bar: 'baz' }),
          status: 200
        )

      expect { connection.post('/roll') }.to raise_error Faraday::Openapi::ResponseInvalidError
    end
  end
end
