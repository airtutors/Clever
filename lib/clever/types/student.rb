# frozen_string_literal: true

module Clever
  module Types
    class Student < Base
      attr_reader :id,
                  :first_name,
                  :last_name,
                  :district_username,
                  :grade,
                  :provider

      def initialize(attributes = {})
        data               = attributes['data']
        @id                = data['id']
        @first_name        = data['name']['first']
        @last_name         = data['name']['last']
        @district_username = data['credentials']['district_username']
        @grade             = data['grade']
        @provider          = 'clever'
      end
    end
  end
end
