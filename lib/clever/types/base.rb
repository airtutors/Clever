# frozen_string_literal: true

module Clever
  module Types
    class Base
      def to_h
        instance_variables.each_with_object({}) do |instance_var, variables|
          key = instance_var.to_s.tr('@', '').to_sym
          value = instance_variable_get(instance_var)
          variables[key] = value
        end
      end

      def presence(field)
        field unless blank?(field)
      end

      def blank?(field)
        field.nil? || field == ''
      end
    end
  end
end
