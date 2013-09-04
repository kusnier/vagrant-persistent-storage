module VagrantPlugins
  module ProviderVirtualBox
    module Driver
      class Base

        def create_adapter
          execute("storagectl", @uuid, "--name", "SATA Controller", "--sataportcount", "2")
        end

        def create_storage(location, size)
          execute("createhd", "--filename", location, "--size", size)
        end

        def attach_storage(location)
          execute("storageattach", @uuid, "--storagectl", "SATA Controller", "--port", "1", "--device", "0", "--type", "hdd", "--medium", "#{location}")
        end

        def detach_storage(location)
          if location and read_persistent_storage(location) == location
            execute("storageattach", @uuid, "--storagectl", "SATA Controller", "--port", "1", "--device", "0", "--type", "hdd", "--medium", "none")
          end
        end

        def read_persistent_storage(location)
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          info.split("\n").each do |line|
            return $1.to_s if line =~ /^"SATA Controller-1-0"="(.+?)"$/
          end
          nil
        end

      end
    end
  end
end

