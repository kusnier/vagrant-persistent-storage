require 'vagrant'
require 'vagrant/action/builder'
require 'vagrant-persistent-storage/config'
require 'vagrant-persistent-storage/middleware'
require 'vagrant-persistent-storage/version'

Vagrant.config_keys.register(:persistent_storage) { VagrantPersistentStorage::Config }
Vagrant.actions[:start].insert_after(Vagrant::Action::VM::ShareFolders, VagrantPersistentStorage::AttachPersistentStorage)
Vagrant.actions[:destroy].insert_after(Vagrant::Action::VM::PruneNFSExports, VagrantPersistentStorage::DetachPersistentStorage)

# Add our custom translations to the load path
#I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)
