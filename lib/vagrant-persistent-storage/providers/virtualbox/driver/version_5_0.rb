module VagrantPlugins
  module ProviderVirtualBox
    module Driver
      class Version_5_0
        def attach_storage(location)
          execute("storageattach", @uuid, "--storagectl", get_controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", "#{location}", "--hotpluggable", "on")
        end
      end
    end
  end
end
