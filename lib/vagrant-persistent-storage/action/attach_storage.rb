require "log4r"

module VagrantPlugins
  module PersistentStorage
    module Action
      class AttachStorage

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]
          @logger = Log4r::Logger.new('vagrant::persistentstorage::action::attachstorage')
        end

        def call(env)

          @logger.info 'Attaching HD'

          env[:ui].info I18n.t("vagrant_persistent_storage.action.attach_storage")
          location = env[:machine].config.persistent_storage.location
          env[:machine].provider.driver.attach_storage(location)

          @app.call(env)

        end

      end
    end
  end
end
