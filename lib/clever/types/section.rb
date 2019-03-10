# frozen_string_literal: true

module Clever
  module Types
    class Section
      attr_reader :id,
                  :name,
                  :period,
                  :grades,
                  :provider

      def initialize(attributes = {})
        data      = attributes['data']
        @id       = data['id']
        @name     = data['name']
        @period   = data['period']
        @grades   = data['grade']
        @provider = 'clever'
      end
    end
  end
end
