Redmine::Plugin.register :rmplus_devtools do
  name 'RMPlus Devtools plugin'
  author 'Alexey Glukhov'
  description 'Collection of tools useful for Redmine developers'
  version '0.1.0'
  url 'https://github.com/pineapple-thief/rmplus_devtools.git'
  author_url 'https://github.com/pineapple-thief'

  settings :partial => 'settings/rmplus_devtools'
end

Rails.application.config.after_initialize do
  if Rails.env.development?
    enable_assets_listeners = Setting.plugin_rmplus_devtools[:enable_assets_listeners]
    if enable_assets_listeners
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
          Rails.logger.debug "Starting assets listener for plugin #{name} in directory #{source}"
          assets_listener.start
          $listeners << assets_listener
        end
      end
      at_exit do
        Rails.logger.debug "Stopping listeners..."
        $listeners.each{ |listener| listener.stop }
      end
    end
  end

end