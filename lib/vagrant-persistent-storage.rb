require 'vagrant-persistent-storage/config'
require 'vagrant-persistent-storage/plugin'

module VagrantPersistentStorage
   def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
   end
end

# Add our custom translations to the load path
#I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

