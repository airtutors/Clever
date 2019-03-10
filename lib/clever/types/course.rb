# frozen_string_literal: true

module Clever
  module Types
    class Course < Base
      attr_reader :id,
                  :district,
                  :name,
                  :number,
                  :provider

      def initialize(attributes = {})
        data      = attributes['data']
        @id       = data['id']
        @district = data['district']
        @name     = data['name']
        @number   = data['number']
        @provider = 'clever'
      end
    end
  end
end
