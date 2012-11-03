module VagrantPersistentStorage
  class DetachPersistentStorage
    def initialize(app, env)
      @app = app
      @env = env
      @vm = env[:vm]
    end

    def call(env)
      options = @vm.config.persistent_storage
      if options.location and read_persistent_storage() == options.location
        @vm.driver.execute("storageattach", @vm.uuid, "--storagectl", "SATA Controller", "--port", "1", "--type", "hdd", "--medium", "none")
        env[:ui].info "Detach Persistent Storage #{options.location} (Size: #{options.size}MB)"
      end

      @app.call(env)
    end

    def read_persistent_storage
      info = @vm.driver.execute("showvminfo", @vm.uuid, "--machinereadable", :retryable => true)
      info.split("\n").each do |line|
        return $1.to_s if line =~ /^"SATA Controller-1-0"="(.+?)"$/
      end

      nil
    end

  end
end
