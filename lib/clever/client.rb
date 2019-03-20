# frozen_string_literal: true

module Clever
  class Client
    attr_accessor :app_id, :app_token, :sync_id, :logger, :vendor_key, :vendor_secret

    attr_reader :api_url, :tokens_endpoint

    def initialize
      @api_url           = API_URL
      @tokens_endpoint   = TOKENS_ENDPOINT
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

    %i[students courses teachers sections].each do |record_type|
      define_method(record_type) do |record_ids = []|
        authenticate unless @app_token

        endpoint = Clever.const_get("#{record_type.upcase}_ENDPOINT")
        type = Types.const_get(record_type.to_s.capitalize[0..-2])

        records = Paginator.fetch(connection, endpoint, :get, type).force

        return records if record_ids.empty?

        records.reject { |record| record_ids.exclude?(record.id) }
      end
    end

    def classrooms
      authenticate unless @app_token

      fetched_courses = courses

      sections.map do |section|
        course = fetched_courses.find { |clever_course| clever_course.id == section.course }
        Types::Classroom.new(section, course&.number)
      end
    end

    def enrollments(classroom_ids = [])
      authenticate unless @app_token

      fetched_sections = sections

      enrollments = fetched_sections.each_with_object(student: [], teacher: []) do |section, enrollments|
        next if classroom_ids.any? && classroom_ids.exclude?(section.id)

        %i[student teacher].each do |kind|
          section.public_send("#{kind}s").each { |record| enrollments[kind] << Types::Enrollment.new(section, record) }
        end
      end

      p "Found #{enrollments.values.flatten.length} enrollments."

      enrollments
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
