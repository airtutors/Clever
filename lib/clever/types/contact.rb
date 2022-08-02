# frozen_string_literal: true

module Clever
  module Types
    class Contact < Base
      attr_reader :uid, :sis_id, :name, :students, :school, :district,
        :phone_type, :phone, :email, :type, :relationship

      def initialize(attributes = {}, *)
        @uid = attributes['id']
        @sis_id = attributes['sis_id']
        @name = attributes['name']
        @students = attributes['students']
        @school = attributes['school']
        @district = attributes['district']
        @phone_type = attributes['phone_type']
        @phone = attributes['phone']
        @email = attributes['email']
        @type = attributes['type']
        @relationship = attributes['relationship']
      end
    end
  end
end
