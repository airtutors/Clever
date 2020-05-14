# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clever::Connection do
  let(:connection) { described_class.new(client) }
  let(:logger) { stub('Logger') }
  let(:vendor_key) { 'vendor_key' }
  let(:vendor_secret) { 'vendor_secret' }
  let(:app_token) { '0ed35a0de3005aa1c77df310ac0375a6158881c4' }
  let(:auth_header) { 'Basic dmVuZG9yX2tleTp2ZW5kb3Jfc2VjcmV0' }
  let(:user_agent) { "Faraday v#{Faraday::VERSION}" }
  let(:app_id) { '5800e1c5e16c4230146fce0' }
  let(:status) { 200 }

  let(:client) do
    Clever::Client.configure do |config|
      config.app_id        = app_id
      config.vendor_key    = vendor_key
      config.vendor_secret = vendor_secret
      config.logger        = logger
    end
  end

  describe '#connection' do
    it 'returns new faraday connection if one does not exist' do
      conn = connection.connection
      expect(conn).to be_a(Faraday::Connection)
      expect(conn.headers['Authorization']).to eq(auth_header)
      expect(conn.headers['User-Agent']).to eq(user_agent)
      expect(conn.builder.handlers).to eq(
        [
          FaradayMiddleware::EncodeJson, Faraday::Response::Logger,
          FaradayMiddleware::ParseJson
        ]
      )
    end

    it 'memoizes the connection' do
      conn = connection.connection
      expect(connection.connection).to eq(conn)
    end

    describe '#execute' do
      let(:status) { 200 }
      let(:body) { 'body' }
      let(:env) { stub(url: stub(path: '/teachers')) }
      let(:mock_response) { stub(status: status, body: body, env: env) }
      context 'successful response' do
        it 'returns a successful response object' do
          connection.expects(:connection).returns(Clever::MockFaradayConnection.new(mock_response))
          response = connection.execute('/teachers', :get, limit: Clever::PAGE_LIMIT)
          expect(response).to be_a(Clever::Response)
          expect(response.success?).to be(true)
          expect(response.raw_body).to eq(mock_response.body)
        end
      end

      context 'failed response' do
        let(:status) { 401 }
        let(:body) { 'unauthorized' }

        it 'returns a failed response object' do
          connection.stubs(:raw_request).returns(mock_response)
          response = connection.execute('/teachers', :get, limit: Clever::PAGE_LIMIT)
          expect(response).to be_a(Clever::Response)
          expect(response.success?).to be(false)
          expect(response.raw_body).to eq(mock_response.body)
        end
      end
    end

    describe '#log' do
      it 'logs properly' do
        logger.expects(:info)

        connection.log('💩')
      end
    end
  end

  describe '#set_token' do
    it 'places token as bearer' do
      connection.set_token(app_token)
      expect(connection.connection.headers['Authorization']).to eq("Bearer #{app_token}")
    end
  end
end
