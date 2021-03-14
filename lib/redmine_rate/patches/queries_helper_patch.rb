module RedmineRate
  module Patches
    # Overwrite QueriesHelper
    module QueriesHelperPatch
      def self.included(base)
        base.send(:prepend, InstanceMethods)
      end

      # Instance methods to add customize values
      module InstanceMethods
        def column_value(column, list_object, value)
          if column.name == :cost && list_object.is_a?(TimeEntry)
            show_number_with_currency value
          elsif column.name == :costs && list_object.is_a?(Issue)
            show_number_with_currency value
          else
            super(column, list_object, value)
          end
        end
      end
    end
  end
end

unless QueriesHelper.included_modules.include?(RedmineRate::Patches::QueriesHelperPatch)
  QueriesHelper.send(:include, RedmineRate::Patches::QueriesHelperPatch)
end
