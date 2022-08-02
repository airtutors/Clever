# frozen_string_literal: true

module Clever
  module Types
    class Section < Base
      attr_reader :uid, :name, :period, :course, :grades, :subjects, :students,
        :teachers, :term_id, :provider, :primary_teacher_uid, :district, :school,
        :section_number, :sis_id, :grade, :subject
      def initialize(attributes = {}, *)
        @uid = attributes['id']
        @name = attributes['name']
        @period = attributes['period']
        @course = attributes['course']
        @district = attributes['district']
        @classroom = attributes.dig('ext', 'classroom')
        @grade = attributes['grade']
        @subject = attributes['subject']
        @school = attributes['school']
        @section_number = attributes['section_number']
        @sis_id = attributes['sis_id']
        @grade = attributes['grade']
        @subject = attributes['subject']
        @grades = [presence(attributes['grade'])].compact
        @subjects = [presence(attributes['subject'])].compact
        @students = attributes['students']
        @teachers = attributes['teachers']
        @term_id =  attributes['term_id']
        @provider = 'clever'
        @primary_teacher_uid = attributes['teacher']
        @created = attributes['created']
        @last_modified = attributes['last_modified']
      end
    end
  end
end
