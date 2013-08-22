require "log4r"
require 'vagrant-persistent-storage/manage_storage'

module VagrantPlugins
  module PersistentStorage
    module Action
      class ManageAll

        include ManageStorage

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = @machine.provider_name
          @logger = Log4r::Logger.new('vagrant::persistent_storage::action::manage_storage')
        end

        def call(env)
          # skip if machine is not running and the action is destroy, halt or suspend
          return @app.call(env) if @machine.state.id != :running && [:destroy, :halt, :suspend].include?(env[:machine_action])
          # skip if machine is not saved and the action is resume
          return @app.call(env) if @machine.state.id != :saved && env[:machine_action] == :resume
          # skip if machine is not running and the action is suspend
          return @app.call(env) if @machine.state.id != :running && env[:machine_action] == :suspend
          
          return @app.call(env) unless env[:machine].config.persistent_storage.enabled?
          return @app.call(env) unless env[:machine].config.persistent_storage.manage?
          @logger.info '** Managing Persistent Storage **'

          env[:ui].info I18n.t('vagrant_persistent_storage.action.manage_storage')
          machine = env[:machine]
          manage_volumes(machine)

          @app.call(env)

        end

      end
    end
  end
end
