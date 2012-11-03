module VagrantPersistentStorage
  class AttachPersistentStorage
    def initialize(app, env)
      @app = app
      @env = env
      @vm = env[:vm]
    end

    def call(env)
      options = @vm.config.persistent_storage
      if !options.location  ^ !options.size
        env[:ui].error "Attach Persistent Storage failed. Location and size must be filled out."
      else

        if !File.exists?(options.location)
          @vm.config.vm.customize ["createhd", "--filename", options.location, "--size", options.size]
          env[:ui].success "Create Persistent Storage."
        end
        @vm.config.vm.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 1, "--type", "hdd", "--medium", options.location]

        env[:ui].info "Attach Persistent Storage #{options.location} (Size: #{options.size}MB)"
      end

      @app.call(env)
    end
  end
end
