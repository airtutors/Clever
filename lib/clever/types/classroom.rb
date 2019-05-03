# frozen_string_literal: true

module Clever
  module Types
    class Classroom < Base
      attr_reader :uid,
                  :name,
                  :period,
                  :course_number,
                  :grades,
                  :provider

      def initialize(attributes = {}, *)
        @uid           = attributes['id']
        @name          = attributes['name']
        @period        = attributes['period']
        @course_number = attributes['course_number']
        @grades        = attributes['grades']
        @provider      = 'clever'
      end
    end
  end
end
