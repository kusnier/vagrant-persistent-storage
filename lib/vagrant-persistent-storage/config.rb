require 'log4r'
require 'pathname'

module VagrantPlugins
  module PersistentStorage
    class Config < Vagrant.plugin('2', :config)

      attr_accessor :size
      attr_accessor :variant
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
      attr_accessor :partition
      attr_accessor :diskdevice
      attr_accessor :filesystem
      attr_accessor :volgroupname
      attr_accessor :drive_letter
      attr_accessor :part_type_code

      alias_method :create?, :create
      alias_method :mount?, :mount
      alias_method :manage?, :manage
      alias_method :format?, :format
      alias_method :use_lvm?, :use_lvm
      alias_method :partition?, :partition
      alias_method :enabled?, :enabled

      def initialize
        @size = UNSET_VALUE
        @variant = UNSET_VALUE
        @create = true
        @mount = true
        @manage = true
        @format = true
        @use_lvm = true
        @enabled = UNSET_VALUE
        @partition = true
        @location = UNSET_VALUE
        @mountname = UNSET_VALUE
        @mountpoint = UNSET_VALUE
        @mountoptions = UNSET_VALUE
        @diskdevice = UNSET_VALUE
        @filesystem = UNSET_VALUE
        @volgroupname = UNSET_VALUE
        @drive_letter = UNSET_VALUE
        @part_type_code = UNSET_VALUE
        @logger = Log4r::Logger.new('vagrant::persistent_storage::config')
      end

      def finalize!
        @size = 0 if @size == UNSET_VALUE
        @variant = "Standard" if @variant == UNSET_VALUE
        @create = true if @create == UNSET_VALUE
        @mount = true if @mount == UNSET_VALUE
        @manage = true if @manage == UNSET_VALUE
        @format = true if @format == UNSET_VALUE
        @use_lvm = true if @use_lvm == UNSET_VALUE
        @partition = true if @partition == UNSET_VALUE
        @enabled = false if @enabled == UNSET_VALUE
        @location = "" if @location == UNSET_VALUE
        @mountname = "" if @mountname == UNSET_VALUE
        @mountpoint = "" if @mountpoint == UNSET_VALUE
        @mountoptions = [] if @mountoptions == UNSET_VALUE
        @diskdevice = "" if @diskdevice == UNSET_VALUE
        @filesystem = "" if @filesystem == UNSET_VALUE
        @volgroupname = "" if @volgroupname == UNSET_VALUE
        @drive_letter = 0 if @drive_letter == UNSET_VALUE
        @part_type_code = "8e" if @part_type_code == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors

        @enabled = false if @enabled == UNSET_VALUE

        errors << validate_bool('persistent_storage.create', @create)
        errors << validate_bool('persistent_storage.mount', @mount)
        errors << validate_bool('persistent_storage.manage', @manage)
        errors << validate_bool('persistent_storage.format', @format)
        errors << validate_bool('persistent_storage.use_lvm', @use_lvm)
        errors << validate_bool('persistent_storage.enabled', @enabled)
        errors << validate_bool('persistent_storage.partition', @partition)
        errors.compact!

        if !machine.config.persistent_storage.size.kind_of?(Integer)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_number', {
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
        if !machine.config.persistent_storage.part_type_code.kind_of?(String)
           errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
             :config_key => 'persistent_storage.part_type_code',
             :is_class   => part_type_code.class.to_s,
           })
        end
        if !machine.config.persistent_storage.volgroupname.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.volgroupname',
            :is_class   => volgroupname.class.to_s,
          })
        end
        if !machine.config.persistent_storage.variant.kind_of?(String)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_string', {
            :config_key => 'persistent_storage.variant',
            :is_class   => variant.class.to_s,
          })
       end

        mount_point_path = Pathname.new("#{machine.config.persistent_storage.location}")
        if ! (mount_point_path.absolute? || mount_point_path.relative?)
          errors << I18n.t('vagrant_persistent_storage.config.not_a_path', {
            :config_key => 'persistent_storage.location',
            :is_path   => location.class.to_s,
          })
        end

        if ! Pathname.new(machine.config.persistent_storage.location).absolute?
          # Non-absolute paths are relative to machine's root directory (where
          # Vagrantfile is placed). Paths under HOME, e.g., ~/disk.vdi), are
          # expanded as expected.
          new_location = File.expand_path(machine.config.persistent_storage.location, machine.env.root_path)
          @logger.info "Found non-absolute location #{machine.config.persistent_storage.location}. Using location #{new_location} instead."
          machine.config.persistent_storage.location = new_location
        end

        machine.ui.info "Using #{machine.config.persistent_storage.location} for persistent storage."

        if ! File.exists?@location.to_s and ! @create == "true"
          errors << I18n.t('vagrant_persistent_storage.config.no_create_and_missing', {
            :config_key => 'persistent_storage.create',
            :is_path   => location.class.to_s,
          })
        end

        { 'Persistent Storage configuration' => errors }
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
