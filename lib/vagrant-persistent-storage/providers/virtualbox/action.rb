require "vagrant/action/builder"

module VagrantPlugins
  module ProviderVirtualBox
    module Action

      autoload :CreateAdapter,             File.expand_path("../action/create_adapter.rb", __FILE__)
      autoload :CreateStorage,             File.expand_path("../action/create_storage.rb", __FILE__)
      autoload :AttachStorage,             File.expand_path("../action/attach_storage.rb", __FILE__)
      autoload :DetachStorage,             File.expand_path("../action/detach_storage.rb", __FILE__)

      def self.create_adapter
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              b2.use CreateAdapter
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.create_storage
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              b2.use CreateStorage
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.attach_storage
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              b2.use AttachStorage
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.detach_storage
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              b2.use DetachStorage
            else
              b2.use MessageNotCreated
            end
          end
        end
      end
    end
  end
end
