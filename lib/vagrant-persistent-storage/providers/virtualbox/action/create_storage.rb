#require 'vagrant-persistent-storage/vbox_storage'

module VagrantPlugins
  module ProviderVirtualBox
    module Action
      class CreateStorage

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]
          @logger = Log4r::Logger.new('vagrant::persistentstorage::create_storage')
        end

        def call(env)
#          # skip if machine is running and the action is resume or up
#          return @app.call(env) if @machine.state.id == :running && [:resume, :up].include?(env[:machine_action])
#          # skip if machine is not running and the action is destroy, halt or suspend
#          return @app.call(env) if @machine.state.id != :running && [:destroy, :halt, :suspend].include?(env[:machine_action])
#          # skip if machine is not saved and the action is resume
#          return @app.call(env) if @machine.state.id != :saved && env[:machine_action] == :resume
#          # skip if machine is not running and the action is suspend
#          return @app.call(env) if @machine.state.id != :running && env[:machine_action] == :suspend

          # check config to see if the disk should be created
          return @app.call(env) unless @machine.config.persistent_storage.create?
          @logger.info 'Creating HD'

          env[:ui].info I18n.t("vagrant.actions.vm.createstorage.creating")
          location = env[:machine].config.persistent_storage.location
          size = env[:machine].config.persistent_storage.size
          env[:machine].provider.driver.create_storage(location, size)

          @app.call(env)

        end

      end
    end
  end
end
