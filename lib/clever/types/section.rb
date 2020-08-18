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
                  :provider,
                  :primary_teacher_uid

      def initialize(attributes = {}, *)
        @uid                 = attributes['id']
        @name                = attributes['name']
        @period              = attributes['period']
        @course              = attributes['course']
        @grades              = [presence(attributes['grade'])].compact
        @subjects            = [presence(attributes['subject'])].compact
        @students            = attributes['students']
        @teachers            = attributes['teachers']
        @term_id             =  attributes['term_id']
        @provider            = 'clever'
        @primary_teacher_uid = attributes['teacher']
      end
    end
  end
end
