module VagrantPersistentStorage

    module ProviderVirtualBox

        module Driver

            class Base

                def storage_detach
                    if options.location and read_persistent_storage() == options.location
                        execute("storageattach", @uuid, "--storagectl", "SATA Controller", "--port", "1", "--type", "hdd", "--medium", "none")
                    end
                end

                def read_persistent_storage
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

