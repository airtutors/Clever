# frozen_string_literal: true

module Clever
  module Types
    class Classroom < Base
      attr_reader :id,
                  :name,
                  :period,
                  :course_number,
                  :grades,
                  :provider

      def initialize(section, course_number)
        @id            = section.id
        @name          = section.name
        @period        = section.period
        @course_number = course_number
        @grades        = section.grades
        @provider      = 'clever'
      end
    end
  end
end
