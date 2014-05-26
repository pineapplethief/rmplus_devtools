require 'rmplus_devtools/rmplus_devtools'

Redmine::Plugin.register :rmplus_devtools do
  name 'RMPlus Devtools plugin'
  author 'Alexey Glukhov'
  description 'Collection of tools useful for Redmine developers'
  version '0.1.0'
  url 'https://github.com/pineapple-thief/rmplus_devtools.git'
  author_url 'https://github.com/pineapple-thief'

  settings :partial => 'settings/rmplus_devtools',
           :default => { 'enable_profiling' => false, 'user_to_profile_ids' => [1] }
end

Rails.application.config.after_initialize do
  RmplusDevtools::AssetsListener.check_listeners
end

Rails.application.config.to_prepare do
  ApplicationController.send(:include, RmplusDevtools::ApplicationControllerPatch)
end