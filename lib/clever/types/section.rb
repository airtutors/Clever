# frozen_string_literal: true

module Clever
  module Types
    class Section < Base
      attr_reader :uid,
                  :name,
                  :period,
                  :course,
                  :grades,
                  :students,
                  :teachers,
                  :provider

      def initialize(attributes = {}, *)
        @uid      = attributes['id']
        @name     = attributes['name']
        @period   = attributes['period']
        @course   = attributes['course']
        @grades   = attributes['grade']
        @students = attributes['students']
        @teachers = attributes['teachers']
        @provider = 'clever'
      end
    end
  end
end
