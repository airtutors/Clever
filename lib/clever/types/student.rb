# frozen_string_literal: true

module Clever
  module Types
    class Student < Base
      attr_reader :id,
                  :first_name,
                  :last_name,
                  :username,
                  :provider

      def initialize(attributes = {})
        data               = attributes['data']
        @id                = data['id']
        @first_name        = data['name']['first']
        @last_name         = data['name']['last']
        district_username  = data['credentials']['district_username']
        @username          = district_username.present? ? district_username : data['sis_id']
        @provider          = 'clever'
      end
    end
  end
end
