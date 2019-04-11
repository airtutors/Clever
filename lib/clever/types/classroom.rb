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

      def initialize(section, course_number, *)
        @uid           = section.uid
        @name          = section.name
        @period        = section.period
        @course_number = course_number
        @grades        = section.grades
        @provider      = 'clever'
      end
    end
  end
end
