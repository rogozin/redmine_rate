require_dependency 'redmine/helpers/time_report'

module RedmineRate
  module Patches
    module TimeReportPatch
      def self.included(base)
        base.send(:prepend, InstanceMethods)
      end

      module InstanceMethods
        def load_available_criteria
          @available_criteria = super
          @available_criteria['billable'] = {
            sql: "#{TimeEntry.table_name}.billable",
            format: 'bool',
            label: :field_billable
          }
          @available_criteria
        end
      end
    end
  end
end

unless Redmine::Helpers::TimeReport.included_modules.include?(RedmineRate::Patches::TimeReportPatch)
  Redmine::Helpers::TimeReport.send(:include, RedmineRate::Patches::TimeReportPatch)
end
