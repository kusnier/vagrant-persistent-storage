require "vagrant/action/builder"
require "vagrant-persistent-storage/action"
require "vagrant-persistent-storage/action/manage_storage"

module VagrantPlugins
  module PersistentStorage
    module Action
      include Vagrant::Action::Builtin

      autoload :CreateAdapter,             File.expand_path("../action/create_adapter.rb", __FILE__)
      autoload :CreateStorage,             File.expand_path("../action/create_storage.rb", __FILE__)
      autoload :AttachStorage,             File.expand_path("../action/attach_storage.rb", __FILE__)
      autoload :DetachStorage,             File.expand_path("../action/detach_storage.rb", __FILE__)
      autoload :ManageStorage,             File.expand_path("../action/manage_storage.rb", __FILE__)

      def self.create_adapter
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use CreateAdapter
        end
      end

      def self.create_storage
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use CreateStorage
        end
      end

      def self.attach_storage
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use AttachStorage
        end
      end

      def self.detach_storage
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use DetachStorage
        end
      end

      def self.manage_storage
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ManageAll
        end
      end

    end
  end
end
