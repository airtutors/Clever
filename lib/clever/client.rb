# frozen_string_literal: true

module Clever
  class Client
    attr_accessor :app_id, :app_token, :sync_id, :logger, :redirect_uri,
                  :vendor_key, :vendor_secret, :username_source, :staff_username_source

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
      return if @app_token

      response = tokens

      fail ConnectionError, response.raw_body unless response.success?

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

    def user_uid_for_code(code)
      response = connection.execute(USER_TOKEN_ENDPOINT,
                                    :post,
                                    nil,
                                    { code: code,
                                      grant_type: 'authorization_code',
                                      redirect_uri: redirect_uri })

      fail ConnectionError, response.raw_body unless response.success?

      connection.set_token(response.raw_body['access_token'])

      response = connection.execute(ME_ENDPOINT, :get)
      response&.body&.dig('id')
    end

    def most_recent_event
      authenticate

      endpoint = "#{Clever::EVENTS_ENDPOINT}?ending_before=last&limit=1"

      event = @connection.execute(endpoint).body[0]
      Types::Event.new(event['data']) if event
    end

    def events(starting_after)
      authenticate

      endpoint = "#{Clever::EVENTS_ENDPOINT}?starting_after=#{starting_after}"
      Paginator.fetch(connection, endpoint, :get, Types::Event, client: self).force
    end

    %i(students courses teachers sections terms contacts schools).each do |record_type|
      define_method(record_type) do |record_uids = []|
        authenticate

        endpoint = Clever.const_get("#{record_type.upcase}_ENDPOINT")
        type = Types.const_get(record_type.to_s.capitalize[0..-2])

        records = Paginator.fetch(connection, endpoint, :get, type, client: self).force

        return records if record_uids.empty?

        record_uids_set = record_uids.to_set
        records.select { |record| record_uids_set.include?(record.uid) }
      end
    end

    def admins(record_uids = [])
      authenticate

      district_admins = Paginator.fetch(connection, Clever::DISTRICT_ADMINS_ENDPOINT,
                                        :get, Types::DistrictAdmin, client: self).force

      school_admins = Paginator.fetch(connection, Clever::SCHOOL_ADMINS_ENDPOINT,
                                      :get, Types::SchoolAdmin, client: self).force

      admins = (district_admins + school_admins).uniq(&:uid)

      return admins if record_uids.empty?

      record_uids_set = record_uids.to_set
      admins.select { |record| record_uids_set.include?(record.uid) }
    end

    # discard params to make the API behave the same as the one roster gem
    def classrooms(*)
      authenticate

      fetched_courses = courses

      terms_hash = terms.each_with_object({}) { |term, terms| terms[term.uid] = term  }

      sections.map do |section|
        course = fetched_courses.find { |clever_course| clever_course.uid == section.course }
        term = terms_hash[section.term_id]
        Types::Classroom.new(
          'id' => section.uid,
          'name' => section.name,
          'period' => section.period,
          'course_number' => course&.number,
          'grades' => section.grades,
          'subjects' => section.subjects,
          'term_name' => term&.name,
          'term_start_date' => term&.start_date,
          'term_end_date' => term&.end_date
        )
      end
    end

    def enrollments(classroom_uids = [])
      authenticate

      fetched_sections = sections

      enrollments = parse_enrollments(classroom_uids, fetched_sections)

      p "Found #{enrollments.values.flatten.length} enrollments."

      enrollments
    end

    def send_grade(request_body)
      authenticate

      @connection.execute(GRADES_ENDPOINT, :post, nil, request_body)
    end

    private

    def parse_enrollments(classroom_uids, sections)
      sections.each_with_object(student: [], teacher: []) do |section, enrollments|
        next if classroom_uids.any? && !classroom_uids.include?(section.uid)

        parse_student_enrollments!(section, enrollments)
        parse_teacher_enrollments!(section, enrollments)
      end
    end

    def parse_student_enrollments!(section, enrollments)
      section.students.each do |student_uid|
        enrollments[:student] << Types::Enrollment.new(
          'classroom_uid' => section.uid,
          'user_uid' => student_uid
        )
      end
    end

    def parse_teacher_enrollments!(section, enrollments)
      section.teachers.each do |teacher_uid|
        enrollments[:teacher] << Types::Enrollment.new(
          'classroom_uid' => section.uid,
          'user_uid' => teacher_uid,
          'primary' => section.primary_teacher_uid == teacher_uid
        )
      end
    end

    def set_token(tokens, app_id)
      district_token = tokens.body.find { |district| district.owner['id'] == app_id }

      fail DistrictNotFound unless district_token

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
