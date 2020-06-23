# frozen_string_literal: true

module Clever
  module Types
    class Term < Base
      attr_reader :uid,
                  :name,
                  :start_date,
                  :end_date

      def initialize(attributes = {}, *)
        @uid        = attributes['id']
        @name       = attributes['name']
        @start_date = attributes['start_date']
        @end_date   = attributes['end_date']
      end
    end
  end
end
