require "log4r"
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

        def create_storage(location, size, variant)
          execute("createhd", "--filename", File.expand_path(location), "--size", "#{size}", "--variant", "#{variant}")
        end

        def attach_storage(location)
          controller_name = get_controller_name
          if controller_name.nil?
            controller_name = "SATA Controller"
          end

          location_realpath = File.expand_path(location)

          if controller_name.start_with?("IDE")
              execute("storageattach", @uuid, "--storagectl", get_controller_name, "--port", "1", "--device", "0", "--type", "hdd", "--medium", "#{location_realpath}")
          elsif controller_name.start_with?("SCSI")
              execute("storageattach", @uuid, "--storagectl", get_controller_name, "--port", "15", "--device", "0", "--type", "hdd", "--medium", "#{location_realpath}")
          else
              execute("storageattach", @uuid, "--storagectl", get_controller_name, "--port", "4", "--device", "0", "--type", "hdd", "--medium", "#{location_realpath}", "--hotpluggable", "on")
          end


        end

        def detach_storage(location)
          location_realpath = File.expand_path(location)
          persistent_storage_data = read_persistent_storage(location_realpath)
          if location and persistent_storage_data and identical_files(persistent_storage_data.location, location_realpath)
              execute("storageattach", @uuid, "--storagectl", persistent_storage_data.controller, "--port", persistent_storage_data.port, "--device", "0", "--type", "hdd", "--medium", "none")
          end
        end

        def read_persistent_storage(location)
          ## Ensure previous operations are complete - bad practise yes, not sure how to avoid this:
          sleep 3
          storage_data = nil
          controller_name = get_controller_name
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          info.split("\n").each do |line|
              tmp_storage_data = nil
              tmp_storage_data = PersistentStorageData.new(controller_name, $1, $3) if line =~ /^"#{controller_name}-(\d+)-(\d+)"="(.*)"/

              if !tmp_storage_data.nil? and tmp_storage_data.location != 'none' and identical_files(File.expand_path(location), tmp_storage_data.location)
                  storage_data = tmp_storage_data
              end
          end
          return storage_data
        end

        def identical_files(file1, file2)
          return (File.exist?(file1) and File.exist?(file2) and File.identical?(Pathname.new(file1).realpath, Pathname.new(file2).realpath))
        end

        def get_controller_name
        controller_number = nil
          controllers = Hash.new
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          info.split("\n").each do |line|
            controllers[$1] = $2 if line =~ /^storagecontrollername(\d+)="(.*)"/
            controller_number = $1 if line =~ /^storagecontrollertype(\d+)="(IntelAhci|PIIX4|LsiLogic)"/
          end

          if controller_number.nil?
            return nil
          end

          return controllers[controller_number]
        end

        class PersistentStorageData

          attr_accessor :controller
          attr_accessor :port
          attr_accessor :location

          def initialize(controller,port,location)
            @controller = controller
            @port = port
            @location = location
          end
        end

      end
    end
  end
end

