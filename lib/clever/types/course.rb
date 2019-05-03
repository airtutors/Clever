# frozen_string_literal: true

module Clever
  module Types
    class Course < Base
      attr_reader :uid,
                  :district,
                  :name,
                  :number,
                  :provider

      def initialize(attributes = {}, *)
        @uid      = attributes['id']
        @district = attributes['district']
        @name     = attributes['name']
        @number   = attributes['number']
        @provider = 'clever'
      end
    end
  end
end
