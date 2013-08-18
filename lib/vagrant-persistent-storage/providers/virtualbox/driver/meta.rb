module VagrantPlugins
  module ProviderVirtualBox
    module Driver
      class Meta

        def_delegators :@driver, 
          :create_storage,
          :attach_storage,
          :detach_storage,
          :read_persistent_storage
 
      end
    end
  end
end

