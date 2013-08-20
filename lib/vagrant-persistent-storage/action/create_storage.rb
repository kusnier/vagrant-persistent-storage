require "log4r"

module VagrantPlugins
  module PersistentStorage
    module Action
      class CreateStorage

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]
          @logger = Log4r::Logger.new('vagrant::persistentstorage::action::createstorage')
        end

        def call(env)
          # check config to see if the disk should be created
          return @app.call(env) unless @machine.config.persistent_storage.create?
          @logger.info 'Creating HD'

          env[:ui].info I18n.t("vagrant_persistent_storage.action.create_storage")
          location = env[:machine].config.persistent_storage.location
          size = env[:machine].config.persistent_storage.size
          env[:machine].provider.driver.create_storage(location, size)

          @app.call(env)

        end

      end
    end
  end
end
