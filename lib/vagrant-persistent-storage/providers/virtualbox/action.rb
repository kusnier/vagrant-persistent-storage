require "vagrant/action/builder"

module VagrantPlugins

    module ProviderVirtualBox

        module Action

            autoload :CreateHd,               File.expand_path("../action/create_hd.rb", __FILE__)
            autoload :ReadPersistentStorage,  File.expand_path("../action/read_persistent_storage.rb", __FILE__)
            autoload :StorageAttach,          File.expand_path("../action/storage_attach.rb", __FILE__)
            autoload :StorageDetach,          File.expand_path("../action/storage_detach.rb", __FILE__)

            def self.action_create_hd
                Vagrant::Action::Builder.new.tap do |b|
                    b.use CheckVirtualbox
                    b.use Call, Created do |env, b2|
                        if env[:result]
                            b2.use CheckAccessible
                            b2.use CreateHd
                        else
                            b2.use MessageNotCreated
                        end
                    end
                end
            end

            def self.action_storage_attach
                Vagrant::Action::Builder.new.tap do |b|
                    b.use CheckVirtualbox
                    b.use Call, Created do |env, b2|
                        if env[:result]
                            b2.use CheckAccessible
                            b2.use StorageAttach
                        else
                            b2.use MessageNotCreated
                        end
                    end
                end
            end

            def self.action_storage_detach
                Vagrant::Action::Builder.new.tap do |b|
                    b.use CheckVirtualbox
                    b.use Call, Created do |env, b2|
                        if env[:result]
                            b2.use CheckAccessible
                            b2.usr StorageDetach
                        else
                            b2.use MessageNotCreated
                        end
                    end
                end
            end

       end

    end

end

 
