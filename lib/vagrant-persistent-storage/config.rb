module VagrantPlugins
  module PersistentStorage
    class Config < Vagrant.plugin('2', :config)

      attr_accessor :create
      attr_accessor :size
      attr_accessor :location
      attr_accessor :mountname
      attr_accessor :mountpoint
      attr_accessor :diskdevice
      attr_accessor :volgroupname

      alias_method :create?, :create

      def initialize
        @create = false
        @size = UNSET_VALUE
        @location = UNSET_VALUE
        @mountname = UNSET_VALUE
        @mountpoint = UNSET_VALUE
        @diskdevice = UNSET_VALUE
        @volgroupname = UNSET_VALUE
      end

      def finalize!
        @create = false if @create == UNSET_VALUE
        @size = 0 if @size == UNSET_VALUE
        @location = 0 if @location == UNSET_VALUE
        @mountname = 0 if @mountname == UNSET_VALUE
        @mountpoint = 0 if @mountpoint == UNSET_VALUE
        @diskdevice = 0 if @diskdevice == UNSET_VALUE
        @volgroupname = 0 if @volgroupname == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors << validate_bool('persistent_storage.create', @create)
        errors.compact!

        if !machine.config.persistent_storage.size.kind_of?(String) and
            !machine.config.persistent_storage.location.kind_of?(String) and
            !machine.config.persistent_storage.mountname.kind_of?(String) and
            !machine.config.persistent_storage.mountpoint.kind_of?(String) and
            !machine.config.persistent_storage.diskdevice.kind_of?(String) and
            !machine.config.persistent_storage.volgroupname.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.size',
            :is_class   => size.class.to_s,
          })
        end

        { 'Persistent Storage configuration' => errors }

        if ! File.exists?@location.to_s and ! @create == "false"
            return { "location" => ["file doesn't exist, and create set to false"] }
        end
        {}
      end

      private

      def validate_bool(key, value)
        if ![TrueClass, FalseClass].include?(value.class) &&
           value != UNSET_VALUE
          I18n.t('vagrant_persistent_storage.config.not_a_bool', {
            :config_key => key,
            :value      => value.class.to_s
          })
        else
          nil
        end

      end

    end
  end
end
