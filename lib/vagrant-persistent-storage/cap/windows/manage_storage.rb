require 'tempfile'
require 'fileutils'
require 'erb'

def populate_template(machine)

  ## windows filesystem options
  drive_letter = machine.config.persistent_storage.drive_letter

  if drive_letter == 0
    drive_letter = ""
  else
    drive_letter = "letter=#{drive_letter}"
  end

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

  buffer = disk_operations_template.result(binding)
  tmp_script = Tempfile.new("disk_operations_#{mnt_name}.ps1")
  target_script = "disk_operations_#{mnt_name}.ps1"

  File.open("#{tmp_script.path}", 'wb') do |f|
    f.write buffer
  end

  machine.communicate.upload(tmp_script.path, target_script)
end

def run_disk_operations(machine)
  return unless machine.communicate.ready?
  target_script = "disk_operations_#{mnt_name}.ps1"
  machine.communicate.sudo("powershell -executionpolicy bypass -file #{target_script}")
end

def manage_volumes(machine)
  populate_template(machine)
  if machine.config.persistent_storage.manage?
    run_disk_operations(machine)
  end
end
