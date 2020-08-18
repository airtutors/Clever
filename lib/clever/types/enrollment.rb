# frozen_string_literal: true

module Clever
  module Types
    class Enrollment < Base
      attr_reader :classroom_uid,
                  :user_uid,
                  :provider,
                  :primary

      def initialize(attributes = {})
        @classroom_uid   = attributes['classroom_uid']
        @user_uid        = attributes['user_uid']
        @provider        = 'clever'
        @primary         = attributes.dig('primary') || false
      end
    end
  end
end
