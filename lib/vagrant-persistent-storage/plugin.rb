require 'vagrant'

module VagrantPlugins
  module PersistentStorage
    class Plugin < Vagrant.plugin('2')

      include Vagrant::Action::Builtin

      require_relative "action"
      require_relative "providers/virtualbox/driver/base"
      require_relative "providers/virtualbox/driver/meta"

      name "persistent_storage"
      description <<-DESC
      This plugin provides config to attach persistent storage
      DESC

      config "persistent_storage" do
        require_relative "config"
        Config
      end

      ## NB Currently only works with Virtualbox provider, due to hooks being used
      action_hook(:persistent_storage, :machine_action_up) do |hook|

        hook.after VagrantPlugins::ProviderVirtualBox::Action::SaneDefaults,
                  VagrantPlugins::PersistentStorage::Action.create_adapter

        hook.after VagrantPlugins::ProviderVirtualBox::Action::Boot,
                  VagrantPlugins::PersistentStorage::Action.create_storage

        hook.before VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions,
                  VagrantPlugins::PersistentStorage::Action.attach_storage

        hook.after VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions,
                  VagrantPlugins::PersistentStorage::Action.manage_storage

        hook.after VagrantPlugins::PersistentStorage::Action.attach_storage,
                  VagrantPlugins::PersistentStorage::Action.manage_storage
      end

      action_hook(:persistent_storage, :machine_action_destroy) do |hook|
        hook.prepend(VagrantPlugins::PersistentStorage::Action.detach_storage)
      end

    end
  end
end
