module RmplusDevtools
  module AssetsListener
    def self.check_listeners
      if Rails.env.development?
        enable_assets_listeners = (Setting.plugin_rmplus_devtools || {})[:enable_assets_listeners] || false
        if enable_assets_listeners
          Rails.logger.debug "Checking symlinks..."
          Redmine::Plugin.registered_plugins.each do |name, plugin|
            Rails.logger.debug "Checking assets symlinks for #{name}"
            source = plugin.assets_directory
            destination = plugin.public_directory
            Rails.logger.debug "    assets source=#{source}"
            Rails.logger.debug "    assets destination=#{destination}"
            if File.directory?(destination) && !File.symlink?(destination)
              Rails.logger.debug "    Destination is directory, not symlink! Deleting it"
              FileUtils.remove_dir(destination)
              Rails.logger.debug "    Creating symlink..."
              FileUtils.symlink(source, destination, :force => true)
            end
          end
        end
      end
    end

  end
end