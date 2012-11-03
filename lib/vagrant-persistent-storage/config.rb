module VagrantPersistentStorage
  class Config < Vagrant::Config::Base
    attr_accessor :location
    attr_accessor :size
  end
end

