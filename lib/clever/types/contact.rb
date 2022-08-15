# frozen_string_literal: true

module Clever
  module Types
    class Contact < Base
      attr_reader :uid, :first_name, :middle_name, :last_name, :students, :school,
                  :district, :phone_type, :phone, :email, :type, :student_relationships

      def initialize(attributes = {}, *)
        @uid = attributes['id']
        @email = attributes['email']
        @first_name = attributes['name']['first']
        @last_name = attributes['name']['last']
        @middle_name = attributes['name']['middle']
        @district = attributes['district']
        @phone = attributes['roles']['contact']['phone']
        @phone_type = attributes['roles']['contact']['phone_type']
        @student_relationships = attributes['roles']['contact']['student_relationships'].map do |attrs|
          StudentRelationship.new(attrs)
        end
      end
    end
  end
end
