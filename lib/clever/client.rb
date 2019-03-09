# frozen_string_literal: true

require 'pry'

module Clever
  class Client
    attr_accessor :app_id, :app_token, :sync_id, :logger, :vendor_key, :vendor_secret

    attr_reader :api_url, :tokens_endpoint

    def initialize
      @api_url         = API_URL
      @tokens_endpoint = TOKENS_ENDPOINT
    end

    def self.configure
      client = new
      yield(client) if block_given?
      client
    end

    def authenticate(app_id = @app_id)
      response = tokens

      raise ConnectionError unless response.success?

      set_token(response, app_id)
    end

    def connection
      @connection ||= Connection.new(self)
    end

    def tokens
      response = connection.execute(@tokens_endpoint)
      map_response!(response, Types::Token)
      response
    end

    def students
      authenticate unless @app_token
      Paginator.fetch(
        connection,
        '/v2.0/students',
        :get,
        Types::Student
      )
      # response = connection.execute '/v2.0/students'
      # map_response!()
    end

    private

    def set_token(tokens, app_id)
      district_token = tokens.body.find { |district| district.owner['id'] == app_id }

      raise DistrictNotFound unless district_token

      connection.set_token(district_token.access_token)

      @app_token = district_token.access_token
    end

    def map_response!(response, type)
      response.body = map_response(type, response.body) if response.success?
    end

    def map_response(type, data)
      data.map { |item_data| type.new(item_data) }
    end
  end
end
