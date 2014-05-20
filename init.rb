Redmine::Plugin.register :rmplus_devtools do
  name 'RMPlus Devtools plugin'
  author 'Alexey Glukhov'
  description 'Collection of tools useful for Redmine developers'
  version '0.1.0'
  url 'https://github.com/pineapple-thief/rmplus_devtools.git'
  author_url 'https://github.com/pineapple-thief'

  settings :partial => 'settings/rmplus_devtools'
end

module RMPlus_Devtools
  def self.start_listeners
    if Rails.env.development?
      enable_assets_listeners = (Setting.plugin_rmplus_devtools || {})[:enable_assets_listeners] || false
      if enable_assets_listeners
        if $listeners.nil? || ($listeners.is_a?(Array) && $listeners.empty?)
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
        end
        at_exit do
          Rails.logger.debug "Stopping listeners..."
          $listeners.each{ |listener| listener.stop }
          $listeners = []
        end
      end
    end
  end
end

Rails.application.config.after_initialize do
  Rails.logger.debug "<<< before_initialize callback!"
  RMPlus_Devtools.start_listeners
end

# ActionDispatch::Callbacks.before do
#   Rails.logger.debug "<<< before callback with actiondispatch!"
#   if defined? $listeners == "global-variable"
#     RMPlus_Devtools.start_listeners
#   end
# end