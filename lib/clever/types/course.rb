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
        data      = attributes['data']
        @uid      = data['id']
        @district = data['district']
        @name     = data['name']
        @number   = data['number']
        @provider = 'clever'
      end
    end
  end
end
