#require 'vagrant-persistent-storage/vbox_storage'

module VagrantPlugins
  module ProviderVirtualBox
    module Action
      class DetachStorage

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @global_env = @machine.env
          @provider = env[:provider]
          @logger = Log4r::Logger.new('vagrant::persistentstorage::create_hd')
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
          @logger.info 'Detaching HD'

          env[:ui].info I18n.t("vagrant.actions.vm.detachstorage.detaching")
          location = env[:machine].config.persistent_storage.location
          env[:machine].provider.driver.detach_storage(location)

          @app.call(env)

        end

      end
    end
  end
end
