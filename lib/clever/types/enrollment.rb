# frozen_string_literal: true

module Clever
  module Types
    class Enrollment < Base
      attr_reader :classroom_uid,
                  :user_uid,
                  :provider

      def initialize(section, user_uid, *)
        @classroom_uid = section.uid
        @user_uid      = user_uid
        @provider      = 'clever'
      end
    end
  end
end
