module VagrantPersistentStorage

    module ProviderVirtualBox

        module Driver

            class Base

                def create_hd
                    if ! File.exists?(options.location)
                        execute("createhd", @uuid, "--filename", options.location, "--size", options.size]
                    end
                end

                def storage_attach
                    execute("storageattach", @uuid, "--storagectl", "SATA Controller", "--port", 1, "--type", "hdd", "--medium", options.location]
                end

            end

        end

    end

end

