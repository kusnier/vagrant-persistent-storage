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
          @logger = Log4r::Logger.new('vagrant::persistent_storage::manage_volumes')
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

          # check config to see if the hosts file should be update automatically
#          return @app.call(env) unless @machine.config.hostmanager.enabled?
          
          @logger.info 'Managing persistent volumes automatically'

          env[:ui].info I18n.t('vagrant_persistent_storage.action.manage_volumes')
          machine = env[:machine]
          manage_volumes(machine)

          @app.call(env)

#          @global_env.active_machines.each do |name, p|
#            if p == @provider
#              machine = @global_env.machine(name, p)
#              manage_volumes(machine)
#            end
#          end

        end
      end
    end
  end
end
