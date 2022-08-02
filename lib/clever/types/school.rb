# frozen_string_literal: true

module Clever
  module Types
    class School < Base
      attr_reader :uid, :district, :name, :high_grade, :low_grade, :state_id, :sis_id,
        :provider, :school_number, :phone, :location, :charter_school, :principal

      def initialize(attributes = {}, *, client: nil)
        @uid = attributes['id']
        @district = attributes['district']
        @high_grade = attributes['high_grade']
        @name = attributes['name']
        @low_grade = attributes['low_grade']
        @state_id = attributes['state_id']
        @school_number = attributes['school_number']
        @phone = attributes['phone']
        @location = attributes['location']
        @charter_school = attributes.fetch('ext', 'charter_school')
        @principal = attributes['principal']
        @sis_id = attributes['sis_id']
        @provider = 'clever'
        @created = attributes['created']
        @last_modified = attributes['last_modified']
      end
    end
  end
end
