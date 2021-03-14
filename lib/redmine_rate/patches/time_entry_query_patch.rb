module RedmineRate
  module Patches
    module TimeEntryQueryPatch
      def self.included(base)
        base.send(:prepend, InstanceMethods)
      end

      module InstanceMethods
        def available_columns
          super
          if @available_columns.none?{|c| c.name == :cost || c.name == :billable }
            @available_columns << QueryColumn.new(:cost,
                                                  sortable: "#{TimeEntry.table_name}.cost",
                                                  totalable: true)

            @available_columns << QueryColumn.new(:billable,
                                                  sortable: "#{TimeEntry.table_name}.billable")
          end
          @available_columns
        end

        def initialize_available_filters
          super

          add_available_filter('cost', name: l(:field_cost), type: :float) unless available_filters.key?('cost')
          return if available_filters.key?('billable')

          add_available_filter('billable',
                               name: l(:field_billable),
                               type: :list,
                               values: [[l(:general_text_yes), '1'], [l(:general_text_no), '0']])
        end

        def total_for_cost(scope)
          map_total(scope.sum(:cost)) { |t| t.to_f.round(2) }
        end
      end
    end
  end
end

unless TimeEntryQuery.included_modules.include?(RedmineRate::Patches::TimeEntryQueryPatch)
  TimeEntryQuery.send(:include, RedmineRate::Patches::TimeEntryQueryPatch)
end
