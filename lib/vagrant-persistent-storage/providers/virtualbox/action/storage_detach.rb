module VagrantPlugins

    module ProviderVirtualBox

        module Action

            class StorageDetach

                def initialize(app, env)
                    @app = app
                end

                def call(env)

                    env[:ui].info I18n.t("vagrant_snap.actions.vm.storagedetach")
                    env[:machine].provider.driver.storage_detach

                    @app.call(env)

                end

            end

        end

    end

end
