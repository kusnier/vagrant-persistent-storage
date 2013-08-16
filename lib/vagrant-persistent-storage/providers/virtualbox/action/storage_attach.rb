module VagrantPlugins

    module ProviderVirtualBox

        module Action

            class StorageAttach

                def initialize(app, env)
                    @app = app
                end

                def call(env)

                    env[:ui].info I18n.t("vagrant_snap.actions.vm.storageattach")
                    env[:machine].provider.driver.storage_attach

                    @app.call(env)

                end

            end

        end

    end

end
