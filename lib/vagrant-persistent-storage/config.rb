require 'pathname'

module VagrantPlugins
  module PersistentStorage
    class Config < Vagrant.plugin('2', :config)

      attr_accessor :size
      attr_accessor :create
      attr_accessor :mount
      attr_accessor :manage
      attr_accessor :format
      attr_accessor :enabled
      attr_accessor :use_lvm
      attr_accessor :location
      attr_accessor :mountname
      attr_accessor :mountpoint
      attr_accessor :mountoptions
      attr_accessor :diskdevice
      attr_accessor :filesystem
      attr_accessor :volgroupname

      alias_method :create?, :create
      alias_method :mount?, :mount
      alias_method :manage?, :manage
      alias_method :format?, :format
      alias_method :use_lvm?, :use_lvm
      alias_method :enabled?, :enabled

      def initialize
        @size = UNSET_VALUE
        @create = true
        @mount = true
        @manage = true
        @format = true
        @use_lvm = true
        @enabled = false
        @location = UNSET_VALUE
        @mountname = UNSET_VALUE
        @mountpoint = UNSET_VALUE
        @mountoptions = UNSET_VALUE
        @diskdevice = UNSET_VALUE
        @filesystem = UNSET_VALUE
        @volgroupname = UNSET_VALUE
      end

      def finalize!
        @size = 0 if @size == UNSET_VALUE
        @create = true if @create == UNSET_VALUE
        @mount = true if @mount == UNSET_VALUE
        @manage = true if @manage == UNSET_VALUE
        @format = true if @format == UNSET_VALUE
        @use_lvm = true if @use_lvm == UNSET_VALUE
        @enabled = false if @enabled == UNSET_VALUE
        @location = 0 if @location == UNSET_VALUE
        @mountname = 0 if @mountname == UNSET_VALUE
        @mountpoint = 0 if @mountpoint == UNSET_VALUE
        @mountoptions = 0 if @mountoptions == UNSET_VALUE
        @diskdevice = 0 if @diskdevice == UNSET_VALUE
        @filesystem = 0 if @filesystem == UNSET_VALUE
        @volgroupname = 0 if @volgroupname == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors << validate_bool('persistent_storage.create', @create)
        errors << validate_bool('persistent_storage.mount', @mount)
        errors << validate_bool('persistent_storage.mount', @manage)
        errors << validate_bool('persistent_storage.mount', @format)
        errors << validate_bool('persistent_storage.mount', @use_lvm)
        errors << validate_bool('persistent_storage.mount', @enabled)
        errors.compact!

        if !machine.config.persistent_storage.size.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.size',
            :is_class   => size.class.to_s,
          })
        end
        if !machine.config.persistent_storage.location.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.location',
            :is_class   => location.class.to_s,
          })
        end
        if !machine.config.persistent_storage.mountname.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.mountname',
            :is_class   => mountname.class.to_s,
          })
        end
        if !machine.config.persistent_storage.mountpoint.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.mountpoint',
            :is_class   => mountpoint.class.to_s,
          })
        end
        if !machine.config.persistent_storage.diskdevice.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.diskdevice',
            :is_class   => diskdevice.class.to_s,
          })
        end
        if !machine.config.persistent_storage.filesystem.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.filesystem',
            :is_class   => filesystem.class.to_s,
          })
        end
        if !machine.config.persistent_storage.volgroupname.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.volgroupname',
            :is_class   => volgroupname.class.to_s,
          })
        end
        
        mount_point_path = Pathname.new("#{machine.config.persistent_storage.location}")
        if ! mount_point.path.absolute?
          errors << I18n.t('vagrant_persistent_storage.config.not_a_path', {
            :config_key => 'persistent_storage.location',
            :is_path   => location.class.to_s,
          })
        end

        { 'Persistent Storage configuration' => errors }

        if ! File.exists?@location.to_s and ! @create == "true"
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
