require 'tempfile'
require 'fileutils'
require 'erb'

def populate_template(machine)
  mnt_name = machine.config.persistent_storage.mountname
  mnt_point = machine.config.persistent_storage.mountpoint
  mnt_options = machine.config.persistent_storage.mountoptions
  vg_name = machine.config.persistent_storage.volgroupname
  disk_dev = machine.config.persistent_storage.diskdevice
  fs_type = machine.config.persistent_storage.filesystem
  manage = machine.config.persistent_storage.manage
  use_lvm = machine.config.persistent_storage.use_lvm
  mount = machine.config.persistent_storage.mount
  format = machine.config.persistent_storage.format

  vg_name = 'vps' unless vg_name != 0
  disk_dev = '/dev/sdb' unless disk_dev != 0
  mnt_name = 'vps' unless mnt_name != 0
  mnt_options = ['defaults'] unless mnt_options != 0
  fs_type = 'ext3' unless fs_type != 0
  if use_lvm
    device = "/dev/#{vg_name}/#{mnt_name}"
  else
    device = "#{disk_dev}1"
  end

  ## shell script to format disk, create/manage LVM, mount disk
  disk_operations_template = ERB.new <<-EOF
#!/bin/bash
# fdisk the disk if it's not a block device already:
re='[0-9][.][0-9.]*[0-9.]*'; [[ $(sfdisk --version) =~ $re ]] && version="${BASH_REMATCH}"
if ! awk -v ver="$version" 'BEGIN { if (ver < 2.26 ) exit 1; }'; then
  [ -b #{disk_dev}1 ] || echo 0,,8e | sfdisk #{disk_dev}
else
  [ -b #{disk_dev}1 ] || echo ,,8e | sfdisk #{disk_dev}
fi
echo "fdisk returned:  $?" >> disk_operation_log.txt

<% if use_lvm == true %>
# Create the physical volume if it doesn't already exist:
[[ `pvs #{disk_dev}1` ]] || pvcreate #{disk_dev}1
echo "pvcreate returned:  $?" >> disk_operation_log.txt
# Create the volume group if it doesn't already exist:
[[ `vgs #{vg_name}` ]] || vgcreate #{vg_name} #{disk_dev}1
echo "vgcreate returned:  $?" >> disk_operation_log.txt
# Create the logical volume if it doesn't already exist:
[[ `lvs #{vg_name} | grep #{mnt_name}` ]] || lvcreate -l 100%FREE -n #{mnt_name} #{vg_name}
echo "lvcreate returned:  $?" >> disk_operation_log.txt
# Activate the volume group if it's inactive:
[[ `lvs #{vg_name} --noheadings --nameprefixes | grep LVM2_LV_ATTR | grep "wi\-a"` ]] || vgchange #{vg_name} -a y
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

  buffer = disk_operations_template.result(binding)
  tmp_script = Tempfile.new("disk_operations_#{mnt_name}.sh")

  target_script = "/tmp/disk_operations_#{mnt_name}.sh"

  File.open("#{tmp_script.path}", 'wb') do |f|
    f.write buffer
  end
 
  machine.communicate.upload(tmp_script.path, target_script)
  machine.communicate.sudo("chmod 755 #{target_script}")
end

def run_disk_operations(machine)
  return unless machine.communicate.ready?
  mnt_name = machine.config.persistent_storage.mountname
  mnt_name = 'vps' unless mnt_name != 0
  target_script = "/tmp/disk_operations_#{mnt_name}.sh"
  machine.communicate.sudo("#{target_script} && rm -f #{target_script}")
end

def manage_volumes(machine)
  populate_template(machine)
  if machine.config.persistent_storage.manage?
    run_disk_operations(machine)
  end
end