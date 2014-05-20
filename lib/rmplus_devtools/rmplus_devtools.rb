module RmplusDevtools
  module AssetsListener
    def self.check_listeners
      if Rails.env.development?
        enable_assets_listeners = (Setting.plugin_rmplus_devtools || {})[:enable_assets_listeners] || false
        if enable_assets_listeners
          Rails.logger.debug "listeners enabled"
          if defined?($listeners) == "global-variable" && ($listeners.nil? || $listeners.blank?) || defined?($listeners).nil?
            Rails.logger.debug "listeners nil or empty or not defined, starting listeners"
            self.start_listeners
          end
        end
      end
    end

    def self.start_listeners
      $listeners = []
      Rails.logger.debug "Initializing listeners..."
      Redmine::Plugin.registered_plugins.each do |name, plugin|
        source = plugin.assets_directory
        if File.exist?(source) && File.directory?(source)
          destination = plugin.public_directory
          assets_listener = Listen.to source do |modified, added, removed|
            modified.each do |modified_path|
              if File.file?(modified_path)
                target = File.join(destination, modified_path.gsub(source, ''))
                FileUtils.cp(modified_path, target)
              end
            end
            added.each do |added_path|
              if File.directory?(added_path)
                FileUtils.mkdir_p(added_path)
              elsif File.file?(added_path)
                target = File.join(destination, added_path.gsub(source, ''))
                FileUtils.cp(added_path, target)
              end
            end
            removed.each do |removed_path|
              target = File.join(destination, removed_path.gsub(source, ''))
              FileUtils.remove_entry(target, true)
            end
          end
          Rails.logger.debug "Starting listener for plugin #{name}"
          assets_listener.start
          $listeners << assets_listener
        end
      end
      at_exit do
        Rails.logger.debug "Stopping listeners..."
        $listeners.each{ |listener| listener.stop }
        $listeners = []
      end
    end

  end
end