require "vagrant/action/builder"
require "vagrant-persistent-storage/action/manage_storage"

module VagrantPlugins
  module PersistentStorage
    module Action
      include Vagrant::Action::Builtin

      def self.manage_storage
        Vagrant::Action::Builder.new.tap do |builder|
#          builder.use ConfigValidate
          builder.use ManageAll
        end
      end

#      def self.update_guest
#        Vagrant::Action::Builder.new.tap do |builder|
#          builder.use ConfigValidate
#          builder.use UpdateGuest
#        end
#      end
#
#      def self.update_host
#        Vagrant::Action::Builder.new.tap do |builder|
#          builder.use UpdateHost
#        end
#      end

    end
  end
end
