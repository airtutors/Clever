# frozen_string_literal: true

module Clever
  module Types
    class Teacher
      attr_reader :id,
                  :email,
                  :first_name,
                  :last_name,
                  :provider

      def initialize(attributes = {})
        data        = attributes['data']
        @id         = data['id']
        @email      = data['email']
        @first_name = data['name']['first']
        @last_name  = data['name']['last']
        @provider   = 'clever'
      end
    end
  end
end
