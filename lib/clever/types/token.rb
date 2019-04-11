# frozen_string_literal: true

module Clever
  module Types
    class Token < Base
      attr_reader :uid,
                  :created,
                  :owner,
                  :access_token,
                  :scopes

      def initialize(attributes = {}, *)
        @uid          = attributes['id']
        @created      = attributes['created']
        @owner        = attributes['owner']
        @access_token = attributes['access_token']
        @scopes       = attributes['scopes']
      end
    end
  end
end
