require 'pathname'

module VagrantPlugins
  module ProviderVirtualBox
    module Driver
      class Base

        def create_adapter
          sata_controller_name = get_sata_controller_name
          if sata_controller_name.nil?
            sata_controller_name = "SATA Controller"
            execute("storagectl", @uuid, "--name", sata_controller_name, "--" + (@version.start_with?("4.3") ? "" : "sata") + "portcount", "2", "--add", "sata")
          else
            execute("storagectl", @uuid, "--name", sata_controller_name, "--" + (@version.start_with?("4.3") ? "" : "sata") + "portcount", "2")
          end
        end

        def create_storage(location, size)
          execute("createhd", "--filename", location, "--size", "#{size}")
        end

        def attach_storage(location)
          execute("storageattach", @uuid, "--storagectl", get_sata_controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", "#{location}")
        end

        def detach_storage(location)
          if location and identical_files(read_persistent_storage(location), location)
            execute("storageattach", @uuid, "--storagectl", get_sata_controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", "none")
          end
        end

        def read_persistent_storage(location)
          ## Ensure previous operations are complete - bad practise yes, not sure how to avoid this:
          sleep 3
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          info.split("\n").each do |line|
            return $1.to_s if line =~ /^"#{get_sata_controller_name}-1-0"="(.+?)"$/
          end
          nil
        end

        def identical_files(file1, file2)
          return File.identical?(Pathname.new(file1).realpath, Pathname.new(file2).realpath)
        end

        def get_sata_controller_name
          controllers = Hash.new
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          info.split("\n").each do |line|
            controllers[$1] = $2 if line =~ /^storagecontrollername(\d+)="(.*)"/
            sata_controller_number = $1 if line =~ /^storagecontrollertype(\d+)="IntelAhci"/
            return controllers[sata_controller_number] unless controllers[sata_controller_number].nil?
          end
          return nil
        end

      end
    end
  end
end

