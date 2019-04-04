# frozen_string_literal: true

module Clever
  module Types
    class Student < Base
      attr_reader :uid,
                  :first_name,
                  :last_name,
                  :provider

      def initialize(attributes = {})
        data               = attributes['data']
        @uid               = data['id']
        @first_name        = data['name']['first']
        @last_name         = data['name']['last']
        @district_username = data['credentials']['district_username']
        @sis_id            = data['sis_id']
        @username          = username
        @provider          = 'clever'
      end

      def username
        @username ||= district_username_blank? ? @sis_id : @district_username
      end

      private

      def district_username_blank?
        @district_username.nil? || @district_username['']
      end
    end
  end
end
