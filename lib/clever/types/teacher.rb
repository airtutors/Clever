# frozen_string_literal: true

module Clever
  module Types
    class Teacher < Base
      attr_reader :uid,
                  :email,
                  :first_name,
                  :last_name,
                  :provider,
                  :legacy_id

      def initialize(attributes = {}, *, client: nil)
        @district_username = attributes.dig('credentials', 'district_username')
        @email             = attributes['email']
        @first_name        = attributes['name']['first']
        @last_name         = attributes['name']['last']
        @legacy_id         = attributes.dig('roles', 'teacher', 'legacy_id')
        @provider          = 'clever'
        @sis_id            = attributes['sis_id']
        @uid               = attributes['id']
        @username          = username(client)
      end

      def username(client = nil)
        username_source = client&.staff_username_source

        @username ||= presence(username_from(username_source))
      end

      def to_h
        {
          uid: @uid,
          email: @email,
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

      def presence(field)
        field unless blank?(field)
      end

      def blank?(field)
        field.nil? || field == ''
      end
    end
  end
end
