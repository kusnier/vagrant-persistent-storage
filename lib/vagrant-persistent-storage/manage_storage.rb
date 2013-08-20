require 'tempfile'
require 'fileutils'
require 'erb'

module VagrantPlugins
  module PersistentStorage
    module ManageStorage

      def populate_template(m)
        mnt_name = m.config.persistent_storage.mountname
        mnt_point = m.config.persistent_storage.mountpoint
        vg_name = m.config.persistent_storage.volgroupname
        disk_dev = m.config.persistent_storage.diskdevice

#        if vg_name == 0
        vg_name = 'vagrant' unless vg_name != 0
#        end

#        if disk_dev == 0
        disk_dev = '/dev/sdb' unless disk_dev != 0
#        end
        
        ## shell script to format disk, create/manage LVM, mount disk
        disk_operations_template = ERB.new <<-EOF
#!/bin/bash
# Format the disk if it's not a block device already:
[ -b #{disk_dev}1 ] || echo 0,,8e | sfdisk #{disk_dev}
echo "fdisk return:  $?" >> script_runner.txt
# Create the physical volume if it doesn't already exist:
[[ `pvs #{disk_dev}1` ]] || pvcreate #{disk_dev}1
echo "pvcreate return:  $?" >> script_runner.txt
# Create the volume group if it doesn't already exist:
[[ `vgs #{vg_name}-vg1` ]] || vgcreate #{vg_name}-vg1 #{disk_dev}1
echo "vgcreate return:  $?" >> script_runner.txt
# Create the logical volume if it doesn't already exist:
[[ `lvs #{vg_name}-vg1 | grep #{mnt_name}` ]] || lvcreate -l 100%FREE -n #{mnt_name} #{vg_name}-vg1
echo "lvcreate return:  $?" >> script_runner.txt
# Activate the volume group if it's inactive:
[[ `lvs #{vg_name}-vg1 --noheadings --nameprefixes | grep LVM2_LV_ATTR | grep "wi\-a"` ]] || vgchange #{vg_name}-vg1 -a y
echo "vgchange return:  $?" >> script_runner.txt
# Create the filesytem if it doesn't already exist
[[ `blkid | grep #{mnt_name}` ]] || mkfs.ext3 /dev/#{vg_name}-vg1/#{mnt_name}
# Create mountpoint #{mnt_point}
[ -d #{mnt_point} ] || mkdir -p #{mnt_point}
# Update fstab with new mountpoint name
[[ `grep -i #{mnt_name} /etc/fstab` ]] || echo /dev/#{vg_name}-vg1/#{mnt_name} #{mnt_point} ext3 defaults 0 0 >> /etc/fstab
# Finally, mount the partition
[[ `mount | grep #{mnt_point}` ]] || mount #{mnt_point}
exit $?
        EOF

        buffer = disk_operations_template.result(binding)
        tmp_script = "/tmp/disk_operations_#{mnt_name}.sh"
        target_script = "/tmp/disk_operations_#{mnt_name}.sh"

        File.open("#{tmp_script}", 'w') do |f|
            f.write buffer
        end
        m.communicate.upload(tmp_script, target_script)
        m.communicate.sudo("chmod 755 #{target_script}")
      end

      def run_disk_operations(m)
        return unless m.communicate.ready?
        mnt_name = m.config.persistent_storage.mountname
        target_script = "/tmp/disk_operations_#{mnt_name}.sh"
        m.communicate.sudo("#{target_script}")
      end

      def manage_volumes(m)
        populate_template(m)
        run_disk_operations(m)
      end

    end
  end
end
