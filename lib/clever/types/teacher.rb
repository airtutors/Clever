# frozen_string_literal: true

module Clever
  module Types
    class Teacher < Base
      attr_reader :uid,
                  :email,
                  :first_name,
                  :last_name,
                  :provider

      def initialize(attributes = {}, *)
        @uid        = attributes['id']
        @email      = attributes['email']
        @first_name = attributes['name']['first']
        @last_name  = attributes['name']['last']
        @provider   = 'clever'
      end
    end
  end
end
