require 'vagrant'

module VagrantPersistentStorage

    class Plugin < Vagrant.plugin("2")

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

    end

end
