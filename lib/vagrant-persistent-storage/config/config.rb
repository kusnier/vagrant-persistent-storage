module VagrantPersistentStorage

  class Config < Vagrant.plugin("2", :config)

      attr_accessor :location
      attr_accessor :size

      def initialize
          @location = UNSET_VALUE
          @size = UNSET_VALUE
      end

      def finalize!
          @location = 0 if @location == UNSET_VALUE
          @size = 0 if @size == UNSET_VALUE
      end

      def validate(machine)
          if ! File.exists?@location 
              return { "location" => ["widgets must be greater than 5"] }
          end
          {}
      end

  end

end

