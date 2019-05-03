# frozen_string_literal: true

module Clever
  PAGE_LIMIT = 10_000

  class Paginator
    def initialize(connection, path, method, type, client: nil)
      @connection = connection
      @path       = path
      @method     = method
      @type       = type
      @client     = client
      @next_path  = nil
    end

    def fetch
      Enumerator.new do |yielder|
        loop do
          response = request(@next_path || @path)
          body = response.body

          fail "Failed to fetch #{@path}" unless response.success?

          body.each { |item| yielder << @type.new(item['data'], client: @client) } if body.any?

          @next_path = response.next_uri

          fail StopIteration unless @next_path
        end
      end.lazy
    end

    def self.fetch(*params)
      new(*params).fetch
    end

    private

    def request(path = @path)
      @connection.execute(path, @method, limit: PAGE_LIMIT)
    end
  end
end
