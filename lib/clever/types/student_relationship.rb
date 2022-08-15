# frozen_string_literal: true

module Clever
  module Types
    class StudentRelationship < Base
      attr_reader :relationship, :student_uid, :type

      def initialize(attributes = {})
        @relationship = attributes['relationship']
        @student_uid = attributes['student']
        @type = attributes['type']
      end
    end
  end
end
