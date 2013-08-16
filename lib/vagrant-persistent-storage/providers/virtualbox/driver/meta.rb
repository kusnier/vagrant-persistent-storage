module VagrantPlugins

    module ProviderVirtualBox

        module Driver

            class Meta

                def_delegators :@driver, :create_hd,
                        :storage_attach,
                        :storage_detach

            end

        end

    end

end
