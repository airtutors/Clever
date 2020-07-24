# frozen_string_literal: true

module Clever
  module Types
    class Student < Base
      attr_reader :uid,
                  :first_name,
                  :last_name,
                  :provider

      def initialize(attributes = {}, client: nil)
        @uid               = attributes['id']
        @first_name        = attributes['name']['first']
        @last_name         = attributes['name']['last']
        @district_username = attributes.dig('credentials', 'district_username')
        @sis_id            = attributes['sis_id']
        @email             = attributes['email']
        @username          = username(client)
        @provider          = 'clever'
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
