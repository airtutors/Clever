# frozen_string_literal: true

module Clever
  module Types
    class DistrictAdmin < Teacher
      def initialize(attributes = {}, *, client: nil)
        @district_username = attributes.dig('roles', 'district_admin', 'credentials', 'district_username')
        @email             = attributes['email']
        @first_name        = attributes['name']['first']
        @last_name         = attributes['name']['last']
        @legacy_id         = attributes.dig('roles', 'district_admin', 'legacy_id')
        @provider          = 'clever'
        @sis_id            = attributes.dig('roles', 'district_admin', 'sis_id')
        @uid               = attributes['id']
        @username          = username(client)
        @role              = 'admin'
      end
    end
  end
end
