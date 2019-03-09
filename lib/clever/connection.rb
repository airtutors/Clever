# frozen_string_literal: true

module Clever
  class Connection
    OPEN_TIMEOUT = 60
    TIMEOUT = 120

    def initialize(client)
      @client = client
    end

    def execute(path, method = :get, params = nil, body = nil)
      Response.new(raw_request(path, method, params, body))
    end

    def set_token(token)
      connection.authorization :Bearer, token
    end

    private

    def connection
      return @connection if @connection

      @connection = Faraday.new(@client.api_url) do |connection|
        connection.request :json
        connection.response :logger, @client.logger if @client.logger
        connection.response :json, content_type: /\bjson$/
        connection.adapter Faraday.default_adapter
      end
      @connection.basic_auth(@client.vendor_key, @client.vendor_secret)
      @connection
    end

    def raw_request(path, method, params, body)
      p "request #{path} #{params}"
      connection.public_send(method) do |request|
        request.options.open_timeout        = OPEN_TIMEOUT
        request.options.timeout             = TIMEOUT
        request.url path, params
        request.headers['Accept-Header'] = 'application/json'
        request.body = body
      end
    end

    def log(msg = '')
      return unless @client.logger
    end
  end
end
