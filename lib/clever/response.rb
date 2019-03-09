# frozen_string_literal: true

module Clever
  class Response
    attr_reader :status, :raw_body, :links, :self_uri, :next_uri

    attr_accessor :body

    def initialize(faraday_response)
      @status   = faraday_response.status
      @raw_body = faraday_response.body

      return unless faraday_response.body

      @body     = faraday_response.body['data']
      @links    = faraday_response.body['links']

      uri(:self)
      uri(:next)
    end

    def success?
      @status == 200
    end

    private

    def uri(kind)
      return unless @links

      object = @links.find { |link| link['rel'] == kind.to_s }

      return unless object

      instance_variable_set("@#{kind}_uri", object['uri'])
    end
  end
end
