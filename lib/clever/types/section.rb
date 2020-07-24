# frozen_string_literal: true

module Clever
  module Types
    class Section < Base
      attr_reader :uid,
                  :name,
                  :period,
                  :course,
                  :grades,
                  :subjects,
                  :students,
                  :teachers,
                  :term_id,
                  :provider

      def initialize(attributes = {}, *)
        @uid      = attributes['id']
        @name     = attributes['name']
        @period   = attributes['period']
        @course   = attributes['course']
        @grades   = attributes['grade']
        @subjects = [presence(attributes['subject'])].compact
        @students = attributes['students']
        @teachers = attributes['teachers']
        @term_id  = attributes['term_id']
        @provider = 'clever'
      end
    end
  end
end
