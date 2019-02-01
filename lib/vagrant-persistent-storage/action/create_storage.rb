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
          @logger = Log4r::Logger.new('vagrant::persistent_storage::action::create_storage')
        end

        def call(env)
          # skip if machine is not running and the action is destroy, halt or suspend
          return @app.call(env) if @machine.state.id != :running && [:destroy, :halt, :suspend].include?(env[:machine_action])
          # skip if machine is not saved and the action is resume
          return @app.call(env) if @machine.state.id != :saved && env[:machine_action] == :resume
          # skip if machine is powered off and the action is resume
          return @app.call(env) if @machine.state.id == :poweroff && env[:machine_action] == :resume
          # skip if machine is saved
          return @app.call(env) if @machine.state.id == :saved

          return @app.call(env) unless env[:machine].config.persistent_storage.enabled?

          # check config to see if the disk should be created
          return @app.call(env) unless env[:machine].config.persistent_storage.create?

          if File.exists?(File.expand_path(env[:machine].config.persistent_storage.location))
            @logger.info '** Persistent Storage Volume exists, not creating **'
            env[:ui].info I18n.t("vagrant_persistent_storage.action.not_creating")
            @app.call(env)

          else
            @logger.info '** Creating Persistent Storage **'
            env[:ui].info I18n.t("vagrant_persistent_storage.action.create_storage")
            location = env[:machine].config.persistent_storage.location
            size = env[:machine].config.persistent_storage.size
            variant = env[:machine].config.persistent_storage.variant
            env[:machine].provider.driver.create_storage(location, size, variant)
            @app.call(env)
          end

        end

      end
    end
  end
end
