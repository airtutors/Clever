# frozen_string_literal: true
require 'pry'

module Clever
  class Client
    attr_accessor :app_id, :sync_id, :logger, :vendor_key, :vendor_secret

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

    def authenticate?
      connection.authenticate?
    end

    def connection
      @connection ||= Connection.new(self)
    end

    def tokens
      response = connection.execute(@tokens_endpoint)
      map_response!(response, Types::Token)
      response
    end

    def map_response!(response, type)
      response.body = map_response(type, response.body['data']) if response.success?
    end

    def map_response(type, data)
      data.map { |item_data| type.new(item_data) }
    end
  end
end
