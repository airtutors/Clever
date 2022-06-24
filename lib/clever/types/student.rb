# frozen_string_literal: true

module Clever
  module Types
    class Student < Base
      attr_reader :district_username, :email, :uid, :first_name, :last_name,
        :middle_name, :provider, :sis_id, :dob, :grade, :enrollments,
        :gifted_status, :gender, :graduation_year, :hispanic_ethnicity, :hispanic_ethnicity,
        :location, :race, :school, :schools, :state_id, :student_number, :username


      def initialize(attributes = {}, client: nil)
        student = attributes.dig('roles', 'student')

        @uid = attributes['id']
        @district_username = student.dig('credentials', 'district_username')
        @email = attributes['email']
        @first_name = attributes['name']['first']
        @last_name = attributes['name']['last']
        @middle_name = attributes['name']['middle']
        @provider = 'clever'
        @sis_id = student['sis_id']
        @dob = student['dob']
        @grade = student['grade']
        @enrollments = student['enrollments']
        @gifted_status = student.dig('ext', 'gifted_status')
        @gender = student['gender']
        @graduation_year = student['graduation_year']
        @hispanic_ethnicity = student['hispanic_ethnicity']
        @location = student['location']
        @race = student['race']
        @school = student['school']
        @schools = student['schools']
        @state_id = student['state_id']
        @student_number = student['student_number']
        @username = username(client)
        @created = attributes['created']
        @last_modified = attributes['last_modified']
      end

      def username(client = nil)
        username_source = client&.username_source

        @username ||= presence(username_from(username_source)) || default_username
      end

      def to_h
        {
          uid: @uid,
          first_name: @first_name,
          last_name: @last_name,
          username: @username,
          provider: @provider
        }
      end

      private

      def username_from(username_source)
        return if blank?(username_source)

        presence(instance_variable_get("@#{username_source}"))
      end

      def default_username
        presence(@district_username) || presence(@email) || @sis_id
      end
    end
  end
end
