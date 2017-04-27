require "log4r"

module VagrantPlugins
  module PersistentStorage
    module Action
      class ManageAll

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
          # skip if machine is powered off and the action is resume
          return @app.call(env) if @machine.state.id == :poweroff && env[:machine_action] == :resume
          # skip if machine is powered off and the action is resume
          return @app.call(env) if @machine.state.id == :saved && env[:machine_action] == :resume

          return @app.call(env) unless env[:machine].config.persistent_storage.enabled?
          return @app.call(env) unless env[:machine].config.persistent_storage.manage?

          guest_name = @machine.guest.name if @machine.guest.respond_to?(:name)
          guest_name ||= @machine.guest.to_s.downcase

          case guest_name
            when /freebsd/
              env[:ui].info I18n.t('vagrant_persistent_storage.guest.freebsd')
              require 'vagrant-persistent-storage/cap/freebsd/manage_storage'
            when /windows/
              env[:ui].info I18n.t('vagrant_persistent_storage.guest.windows')
              require 'vagrant-persistent-storage/cap/windows/manage_storage'
            else
              env[:ui].info I18n.t('vagrant_persistent_storage.guest.linux')
              require 'vagrant-persistent-storage/cap/linux/manage_storage'
          end

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
