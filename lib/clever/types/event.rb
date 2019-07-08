# frozen_string_literal: true

require 'clever/types/section'
require 'clever/types/teacher'
require 'clever/types/student'

module Clever
  module Types
    class Event < Base
      attr_reader :uid,
                  :type,
                  :action,
                  :object,
                  :provider

      TYPE_MAP = {
        'sections' => ::Clever::Types::Section,
        'teachers' => ::Clever::Types::Teacher,
        'students' => ::Clever::Types::Student
      }.freeze

      def initialize(attributes = {}, *)
        @uid           = attributes['id']
        @type, @action = attributes['type'].split('.')
        @object        = TYPE_MAP[@type]&.new(attributes['data']['object'])
        @provider      = 'clever'
      end
    end
  end
end
