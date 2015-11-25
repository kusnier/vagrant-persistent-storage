require 'pathname'

module VagrantPlugins
  module ProviderVirtualBox
    module Driver
      class Base

        def create_adapter
          controller_name = get_controller_name
          if controller_name.nil?
            controller_name = "SATA Controller"
            execute("storagectl", @uuid, "--name", controller_name, "--" + ((@version.start_with?("4.3") || @version.start_with?("5.")) ? "" : "sata") + "portcount", "2", "--add", "sata")
          else
            execute("storagectl", @uuid, "--name", controller_name, "--" + ((@version.start_with?("4.3") || @version.start_with?("5.")) ? "" : "sata") + "portcount", "2")
          end
        end

        def create_storage(location, size)
          execute("createhd", "--filename", location, "--size", "#{size}")
        end

        def attach_storage(location)
          controller_name = get_controller_name
          if controller_name.nil?
            controller_name = "SATA Controller"
          end

          if controller_name == "IDE Controller"
              execute("storageattach", @uuid, "--storagectl", get_controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", "#{location}")
          else
              execute("storageattach", @uuid, "--storagectl", get_controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", "#{location}", "--hotpluggable", "on")
          end


        end

        def detach_storage(location)
          persistent_storage = read_persistent_storage()
          if location and persistent_storage and persistent_storage != "none" and identical_files(persistent_storage, location)
            execute("storageattach", @uuid, "--storagectl", get_controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", "none")
          end
        end

        def read_persistent_storage()
          ## Ensure previous operations are complete - bad practise yes, not sure how to avoid this:
          sleep 3
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          info.split("\n").each do |line|
            return $1.to_s if line =~ /^"#{get_controller_name}-1-0"="(.+?)"$/
          end
          nil
        end

        def identical_files(file1, file2)
          return File.identical?(Pathname.new(file1).realpath, Pathname.new(file2).realpath)
        end

        def get_controller_name
        controller_number = nil
          controllers = Hash.new
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          info.split("\n").each do |line|
            controllers[$1] = $2 if line =~ /^storagecontrollername(\d+)="(.*)"/
            controller_number = $1 if line =~ /^storagecontrollertype(\d+)="(IntelAhci|PIIX4)"/
          end

          if controller_number.nil?
            return nil
          end

          return controllers[controller_number]
        end

      end
    end
  end
end

