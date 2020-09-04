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
            execute("storagectl", @uuid, "--name", controller_name, "--" + (self.remove_prefix(@version) ? "" : "sata") + "portcount", "2", "--add", "sata")
          else
            execute("storagectl", @uuid, "--name", controller_name, "--" + (self.remove_prefix(@version) ? "" : "sata") + "portcount", "2")
          end
        end

        def remove_prefix(vbox_version)
           return vbox_version.start_with?("4.3") || vbox_version.start_with?("5.") || vbox_version.start_with?("6.")
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
              execute("closemedium", "disk", persistent_storage_data.image)
          end
        end

        def read_persistent_storage(location)
          ## Ensure previous operations are complete - bad practise yes, not sure how to avoid this:
          sleep 3
          storage_data = nil
          controller_name = get_controller_name
          info = execute("showvminfo", @uuid, "--machinereadable", :retryable => true)
          # Parse the following two lines matching the controller name:
          # "SATA Controller-4-0"="/data/my-persistent-disk.vdi"
          # "SATA Controller-ImageUUID-4-0"="1b5c4a17-3f84-49ba-b394-bfc609f30283"
          # The first reports the underlying file, while the second reports the
          # UUID of the VirtualBox medium.
          info.split("\n").each do |line|
              tmp_storage_data = nil
              tmp_storage_data = PersistentStorageData.new(controller_name, $1, $3, nil) if line =~ /^"#{controller_name}-(\d+)-(\d+)"="(.*)"/

              tmp_storage_data_image = nil
              tmp_storage_data_image = $3 if line =~ /^"#{controller_name}-ImageUUID-(\d+)-(\d+)"="(.*)"/

              if !tmp_storage_data.nil? and tmp_storage_data.location != 'none' and identical_files(File.expand_path(location), tmp_storage_data.location)
                  storage_data = tmp_storage_data
              end

              # XXX: The ImageUUID line comes second and thus we have already
              # storage_data initialized.
              if !storage_data.nil? and !tmp_storage_data_image.nil?
                  storage_data.image = tmp_storage_data_image
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
          attr_accessor :image

          def initialize(controller,port,location,image)
            @controller = controller
            @port = port
            @location = location
            @image = image
          end
        end

      end
    end
  end
end
