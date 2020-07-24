# frozen_string_literal: true

module Clever
  module Types
    class Classroom < Base
      attr_reader :uid,
                  :name,
                  :period,
                  :course_number,
                  :grades,
                  :subjects,
                  :provider,
                  :term_name,
                  :term_start_date,
                  :term_end_date

      def initialize(attributes = {}, *)
        @uid             = attributes['id']
        @name            = attributes['name']
        @period          = attributes['period']
        @course_number   = attributes['course_number']
        @grades          = attributes['grades']
        @subjects        = attributes['subjects']
        @term_name       = attributes['term_name']
        @term_start_date = attributes['term_start_date']
        @term_end_date   = attributes['term_end_date']
        @provider        = 'clever'
      end
    end
  end
end
