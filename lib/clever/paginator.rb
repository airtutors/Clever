# frozen_string_literal: true

module Clever
  PAGE_LIMIT  = 10_000
  EVENT_TYPES = %w(students teachers sections).freeze

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

          body.each { |item| add_record(yielder, item) } if body.any?

          @next_path = response.next_uri

          fail StopIteration unless @next_path
        end
      end.lazy
    end

    def self.fetch(*args, **kwargs)
      new(*args, **kwargs).fetch
    end

    private

    def add_record(yielder, item)
      return unless should_add_record?(item)

      yielder << @type.new(item['data'], client: @client)
    end

    def should_add_record?(item)
      return true unless @type == Clever::Types::Event

      item['data']['type'].start_with?(*EVENT_TYPES)
    end

    def request(path = @path)
      @connection.execute(path, @method, limit: PAGE_LIMIT)
    end
  end
end
