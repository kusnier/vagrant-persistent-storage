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
          # skip if machine is not running and the action is destroy, halt or suspend
          return @app.call(env) if @machine.state.id != :running && [:destroy, :halt, :suspend].include?(env[:machine_action])
          # skip if machine is saved
          return @app.call(env) if @machine.state.id == :saved

          return @app.call(env) unless env[:machine].config.persistent_storage.enabled?
          @logger.info '** Attaching Persistent Storage **'

          env[:ui].info I18n.t("vagrant_persistent_storage.action.attach_storage")
          location = env[:machine].config.persistent_storage.location
          env[:machine].provider.driver.attach_storage(location)

          @app.call(env)

        end

      end
    end
  end
end
