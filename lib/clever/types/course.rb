# frozen_string_literal: true

module Clever
  module Types
    class Course
      attr_reader :id,
                  :district,
                  :name,
                  :number

      def initialize(attributes = {})
        data      = attributes['data']
        @id       = data['id']
        @district = data['district']
        @name     = data['name']
        @number   = data['number']
      end
    end
  end
end
