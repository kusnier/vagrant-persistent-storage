require 'vagrant'

module VagrantPlugins

  module PersistentStorage

    class Plugin < Vagrant.plugin('2')

      require_relative "providers/virtualbox/action"
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

      action_hook(:persistent_storage, :machine_action_up) do |hook|
        hook.append(VagrantPlugins::ProviderVirtualBox::Action.create_storage)
        hook.append(VagrantPlugins::ProviderVirtualBox::Action.attach_storage)
      end

      action_hook(:persistent_storage, :machine_action_destroy) do |hook|
        hook.prepend(VagrantPlugins::ProviderVirtualBox::Action.detach_storage)
      end

    end

  end

end
