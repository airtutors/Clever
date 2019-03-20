# frozen_string_literal: true

module Clever
  module Types
    class Enrollment < Base
      attr_reader :classroom_id,
                  :user_id,
                  :provider

      def initialize(section, user_id)
        @classroom_id = section.id
        @user_id = user_id
        @provider = 'clever'
      end
    end
  end
end
