module VagrantPlugins

    module ProviderVirtualBox

        module Action

            class CreateHd

                def initialize(app, env)
                    @app = app
                end

                def call(env)

                    env[:ui].info I18n.t("vagrant_snap.actions.vm.createhd")
                    env[:machine].provider.driver.create_hd

                    @app.call(env)

                end

            end

        end

    end

end
