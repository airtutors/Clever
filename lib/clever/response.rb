# frozen_string_literal: true

module Clever
  class Response
    attr_reader :status, :raw_body, :links

    attr_accessor :body

    def initialize(faraday_response)
      @status   = faraday_response.status
      @raw_body = faraday_response.body
      @body     = faraday_response.body
      @links    = faraday_response.body['links'] if faraday_response.body
    end

    def success?
      @status == 200
    end
  end
end
