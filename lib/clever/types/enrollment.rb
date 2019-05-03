# frozen_string_literal: true

module Clever
  module Types
    class Enrollment < Base
      attr_reader :classroom_uid,
                  :user_uid,
                  :provider

      def initialize(attributes = {})
        @classroom_uid = attributes['classroom_uid']
        @user_uid      = attributes['user_uid']
        @provider      = 'clever'
      end
    end
  end
end
