# frozen_string_literal: true

module Clever
  module Types
    class Token < Base
      attr_reader :id,
                  :created,
                  :owner,
                  :access_token,
                  :scopes

      def initialize(attributes = {})
        @id           = attributes['id']
        @created      = attributes['created']
        @owner        = attributes['owner']
        @access_token = attributes['access_token']
        @scopes       = attributes['scopes']
      end
    end
  end
end
