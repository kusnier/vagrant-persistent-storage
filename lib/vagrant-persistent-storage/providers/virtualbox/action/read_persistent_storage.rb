module VagrantPlugins

    module ProviderVirtualBox

        module Action

            class ReadPersistentStorage

                def initialize(app, env)
                    @app = app
                end

                def call(env)

                    env[:ui].info I18n.t("vagrant_snap.actions.vm.readpersistentstorage")
                    env[:machine].provider.driver.read_persistent_storage

                    @app.call(env)

                end

            end

        end

    end

end
