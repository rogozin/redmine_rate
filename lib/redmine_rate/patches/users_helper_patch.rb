require_dependency 'users_helper'

module RedmineRate
  module Patches
    module UsersHelperPatch
      def self.included(base)
        base.send(:prepend, InstanceMethods)
        base.class_eval do
          # Similar to +project_options_for_select+ but allows selecting the active value
          def project_options_for_select_with_selected(projects, selected = nil)
            options = content_tag('option', "--- #{l(:rate_label_default)} ---", value: '')
            projects_by_root = projects.group_by(&:root)
            projects_by_root.keys.sort.each do |root|
              root_selected = root == selected ? 'selected' : nil

              options << content_tag('option', h(root.name), value: root.id, disabled: !projects.include?(root), selected: root_selected)
              projects_by_root[root].sort.each do |project|
                next if project == root
                child_selected = project == selected ? 'selected' : nil

                project_name = "&#187; #{h project.name}".html_safe
                options << content_tag('option', project_name, value: project.id, selected: child_selected)
              end
            end
            options
          end
        end
      end

      module InstanceMethods
        # Adds a rates tab to the user administration page
        def user_settings_tabs
          tabs = super
          tabs << { name: 'rates', partial: 'users/rates', label: :rate_label_rate_history }
        end
      end
    end
  end
end

unless UsersHelper.included_modules.include?(RedmineRate::Patches::UsersHelperPatch)
  UsersHelper.send(:include, RedmineRate::Patches::UsersHelperPatch)
end
