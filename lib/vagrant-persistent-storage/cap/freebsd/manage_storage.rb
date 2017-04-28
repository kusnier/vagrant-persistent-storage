require 'tempfile'
require 'fileutils'
require 'erb'

def populate_template(machine)
  mnt_name = machine.config.persistent_storage.mountname
  mnt_point = machine.config.persistent_storage.mountpoint
  mnt_options = machine.config.persistent_storage.mountoptions
  disk_dev = machine.config.persistent_storage.diskdevice
  fs_type = machine.config.persistent_storage.filesystem
  manage = machine.config.persistent_storage.manage
  mount = machine.config.persistent_storage.mount
  format = machine.config.persistent_storage.format

  disk_dev = '/dev/ada1' unless disk_dev != 0

  # In case disk_dev is /dev/ada1 the device is ada1
  device = disk_dev.split("/").last

  mnt_options = ['defaults'] unless mnt_options != 0
  fs_type = 'ufs' unless fs_type != 0

  ## shell script to format disk, create/manage LVM, mount disk
  disk_operations_template = ERB.new <<-EOF
#!/bin/sh

[ -c #{disk_dev} ] || exit 1

OLD_POOL=$(zdb -l /dev/ada1 | grep '^[[:space:]]*name' | cut -f 2 -d"\'" | head -1)

# We check if there is a prior zpool in device
if [ -z "${OLD_POOL}" ]; then
  # Device is empty, then we create a zpool in it
  zpool create -f #{mnt_name} #{disk_dev} || exit 1
else
  if [ "${OLD_POOL}" == "#{mnt_name}" ]; then
    # There is a prior zpool in device that matches our setting
    zpool list | grep -iq #{mnt_name}

    if [ $? -gt 0 ]; then
      # The zpool is not imported
      zpool import -f #{mnt_name} || exit 1
    fi
  else
    # The prior zpool in device differs from our setting
    # so we import it with requested name
    zpool import -f ${OLD_POOL} #{mnt_name}
  fi
fi

<% if mount == true %>
zfs set mountpoint=#{mnt_point} #{mnt_name} || exit 1
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