require 'tempfile'
require 'fileutils'
require 'erb'

module VagrantPlugins
  module PersistentStorage
    module ManageStorage
      def populate_template(m)
        mnt_name = m.config.persistent_storage.mountname
        mnt_point = m.config.persistent_storage.mountpoint
        mnt_options = m.config.persistent_storage.mountoptions
        vg_name = m.config.persistent_storage.volgroupname
        disk_dev = m.config.persistent_storage.diskdevice
        fs_type = m.config.persistent_storage.filesystem
        manage = m.config.persistent_storage.manage
        use_lvm = m.config.persistent_storage.use_lvm
        mount = m.config.persistent_storage.mount
        format = m.config.persistent_storage.format

		## windows filesystem options
		drive_letter = m.config.persistent_storage.drive_letter

		if m.config.vm.communicator == :winrm
			os = "windows"
		else
			os = "linux"
		end

        vg_name = 'vps' unless vg_name != 0
        disk_dev = '/dev/sdb' unless disk_dev != 0
        mnt_name = 'vps' unless mnt_name != 0
        mnt_options = ['defaults'] unless mnt_options != 0
        fs_type = 'ext3' unless fs_type != 0
        if use_lvm
          device = "/dev/#{vg_name}-vg1/#{mnt_name}"
        else
          device = "#{disk_dev}1"
        end
		if drive_letter == 0
			drive_letter = ""
		else
			drive_letter = "letter=#{drive_letter}"
		end
		
		if os == "windows"
			## shell script for windows to create NTFS partition and assign drive letter
			disk_operations_template = ERB.new <<-EOF
			<% if format == true %>
			foreach ($disk in get-wmiobject Win32_DiskDrive -Filter "Partitions = 0"){
				$disk.DeviceID
				$disk.Index
				"select disk "+$disk.Index+"`r clean`r create partition primary`r format fs=ntfs unit=65536 quick`r active`r assign #{drive_letter}" | diskpart >> disk_operation_log.txt
			}
			<% end %>
			EOF
		else
		## shell script to format disk, create/manage LVM, mount disk
        disk_operations_template = ERB.new <<-EOF
#!/bin/bash
# fdisk the disk if it's not a block device already:
[ -b #{disk_dev}1 ] || echo 0,,8e | sfdisk #{disk_dev}
echo "fdisk returned:  $?" >> disk_operation_log.txt

<% if use_lvm == true %>
# Create the physical volume if it doesn't already exist:
[[ `pvs #{disk_dev}1` ]] || pvcreate #{disk_dev}1
echo "pvcreate returned:  $?" >> disk_operation_log.txt
# Create the volume group if it doesn't already exist:
[[ `vgs #{vg_name}-vg1` ]] || vgcreate #{vg_name}-vg1 #{disk_dev}1
echo "vgcreate returned:  $?" >> disk_operation_log.txt
# Create the logical volume if it doesn't already exist:
[[ `lvs #{vg_name}-vg1 | grep #{mnt_name}` ]] || lvcreate -l 100%FREE -n #{mnt_name} #{vg_name}-vg1
echo "lvcreate returned:  $?" >> disk_operation_log.txt
# Activate the volume group if it's inactive:
[[ `lvs #{vg_name}-vg1 --noheadings --nameprefixes | grep LVM2_LV_ATTR | grep "wi\-a"` ]] || vgchange #{vg_name}-vg1 -a y
echo "vg activation returned:  $?" >> disk_operation_log.txt
<% end %>

<% if format == true  %>
# Create the filesytem if it doesn't already exist
MNT_NAME=#{mnt_name}
[[ `blkid | grep ${MNT_NAME:0:16} | grep #{fs_type}` ]] || mkfs.#{fs_type} -L #{mnt_name} #{device}
echo "#{fs_type} creation return:  $?" >> disk_operation_log.txt
<% if mount == true %>
# Create mountpoint #{mnt_point}
[ -d #{mnt_point} ] || mkdir -p #{mnt_point}
# Update fstab with new mountpoint name
[[ `grep -i #{device} /etc/fstab` ]] || echo #{device} #{mnt_point} #{fs_type} #{mnt_options.join(',')} 0 0 >> /etc/fstab
echo "fstab update returned:  $?" >> disk_operation_log.txt
# Finally, mount the partition
[[ `mount | grep #{mnt_point}` ]] || mount #{mnt_point}
echo "#{mnt_point} mounting returned:  $?" >> disk_operation_log.txt
<% end %>
<% end %>
exit $?
        EOF
		end

        buffer = disk_operations_template.result(binding)
		tmp_script = Tempfile.new("disk_operations_#{mnt_name}.sh")

		if os == 'windows'
			target_script = "disk_operations_#{mnt_name}.ps1"
		else
			target_script = "/tmp/disk_operations_#{mnt_name}.sh"
		end

        File.open("#{tmp_script.path}", 'wb') do |f|
            f.write buffer
        end
        m.communicate.upload(tmp_script.path, target_script)
		unless os == 'windows'
			m.communicate.sudo("chmod 755 #{target_script}")
		end
      end

      def run_disk_operations(m)
        return unless m.communicate.ready?
        mnt_name = m.config.persistent_storage.mountname
        mnt_name = 'vps' unless mnt_name != 0
		if m.config.vm.communicator == :winrm
			target_script = "disk_operations_#{mnt_name}.ps1"
			m.communicate.sudo("powershell -executionpolicy bypass -file #{target_script}")
		else
			target_script = "/tmp/disk_operations_#{mnt_name}.sh"
			m.communicate.sudo("#{target_script}")
		end

      end

      def manage_volumes(m)
        populate_template(m)
        if m.config.persistent_storage.manage?
          run_disk_operations(m)
        end
      end

    end
  end
end
