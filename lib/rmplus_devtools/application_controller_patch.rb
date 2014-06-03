module RmplusDevtools

  module ApplicationControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        after_filter :rack_mini_profiler
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def rack_mini_profiler
        enable_profiling = Setting.plugin_rmplus_devtools['enable_profiling'] || Redmine::Plugin::registered_plugins[:rmplus_devtools].settings['enable_profiling']
        profiling_user_ids = Setting.plugin_rmplus_devtools['user_to_profile_ids'] || Redmine::Plugin::registered_plugins[:rmplus_devtools].settings[:default]['user_to_profile_ids']

        users = User.find(profiling_user_ids) || []

        if enable_profiling and User.current.active?
          if users.respond_to?('include?')
            if (users.include?(User.current))
              Rack::MiniProfiler.authorize_request
            end
          end
        end
      end

    end

  end
end