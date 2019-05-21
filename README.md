# Vagrant::Persistent-Storage

A Vagrant plugin that creates a persistent storage and attaches it to guest machine.

Requires Virtualbox 5

## Installation

    $ vagrant plugin install vagrant-persistent-storage

## Usage

After installing you can set the location and size of the persistent storage.

The following options will create a persistent storage with 5000 MB, named mysql,
mounted on /var/lib/mysql, in a volume group called 'myvolgroup'
```ruby
config.persistent_storage.enabled = true
config.persistent_storage.location = "~/development/sourcehdd.vdi"
config.persistent_storage.size = 5000
config.persistent_storage.mountname = 'mysql'
config.persistent_storage.filesystem = 'ext4'
config.persistent_storage.mountpoint = '/var/lib/mysql'
config.persistent_storage.volgroupname = 'myvolgroup'
```

With `config.persistent_storage.mountoptions` you can change the mount options (default: defaults).  
An example which sets `prjquota` option with xfs.
```ruby
config.persistent_storage.mountname    = 'xfs'
config.persistent_storage.filesystem   = 'xfs'
config.persistent_storage.mountpoint   = '/mnt/xfs'
config.persistent_storage.mountoptions = ['defaults', 'prjquota']
```

Device defaults to `/dev/sdb`. For boxes with multiple disks, make sure you increment the drive:
```ruby
config.persistent_storage.diskdevice = '/dev/sdc'
```

If you are using LVM and you would prefer to use the disk rather than a partition, you can set the following configuration:
```ruby
config.persistent_storage.partition = false
```

When you expect a lot of writes in the disk (the case for `/home` mountpoints) it is recommended to change the disk variant to `Fixed` (fixed allocation) instead of the default `Standard` (dyanamic allocation). The tested types are `Standard` (default) and `Fixed`.
```ruby
config.persistent_storage.variant    = 'Fixed'
```

Every `vagrant up` will attach this file as hard disk to the guest machine.
A `vagrant destroy` will detach the storage to avoid deletion of the storage by vagrant.
A `vagrant destroy` generally destroys all attached drives. See [VBoxManage unregistervm --delete option][vboxmanage_delete].

The disk is initialized and added to it's own volume group as specfied in the config; 
this defaults to 'vagrant'. An ext4 filesystem is created and the disk mounted appropriately,
with entries added to fstab ... subsequent runs will mount this disk with the options specified.

## Windows Guests

Windows Guests must use the WinRM communicator by setting `vm.communicator = 'winrm'`.  An additional option is provided to 
allow you to set the drive letter using:

```ruby
config.persistent_storage.drive_letter = 'Z'
```

Options that are irrelevent to Windows are ignored, such as `mountname`, `filesystem`, `mountpoint` and `volgroupname`.

## How Is The Storage Created?

Based on the configuration provided, during a `vagrant up` a bash script is generated and uploaded to `$tmpdir/disk_operations_#{mnt_name}.sh` (Linux) or `disk_operations_#{mnt_name}.ps1` (Windows).  If the box has not been previously provisioned the script is executed on a `vagrant up`.  To force the script to be executed again you can run `vagrant provision` or if you have halted the box, `vagrant up --provision`.

The outcome of the script being run is placed in the home drive of the vagrant user in a file called `disk_operation_log.txt`.

## Optional settings

```ruby
config.persistent_storage.part_type_code = '82'
```

## Troubleshooting

If your box is not using LVM you must set `config.persistent_storage.use_lvm = false`.

## Supported Providers

* Only the VirtualBox provider is supported.

## Contributors

* [madAndroid](https://github.com/madAndroid)
* [Jeremiah Snapp](https://github.com/jeremiahsnapp)
* [Hiroya Ito](https://github.com/hiboma)
* [joshuata](https://github.com/joshuata)
* [Ciprian Zaharie](https://github.com/bucatzel)
* [aishahalim](https://github.com/aishahalim)
* [Dick Tang](https://github.com/dictcp)
* [dsmaher](https://github.com/dsmaher)
* [Marsup](https://github.com/Marsup)
* [k2s](https://github.com/k2s)
* [vvavrychuk](https://github.com/vvavrychuk)
* [Lars Hupfeldt Nielsen](https://github.com/lhupfeldt)
* [Chen Yu Pao](https://github.com/windperson)
* [Kris Reese](https://github.com/ktreese)
* [Henry N.](https://github.com/HenryNe)
* [fredleger](https://github.com/fredleger)
* [Sebastian Wendel](https://github.com/sourceindex)
* [Ben Phegan](https://github.com/BenPhegan)
* [Philipp Schrader](https://github.com/philsc)
* [Alex Tomkins](https://github.com/tomkins)
* [Marcin Wolny](https://github.com/mwolny)
* [Adam Huffman](https://github.com/verdurin)
* [caio2k](https://github.com/caio2k)
* [Francesco](https://github.com/cisco87)
* [Dimitris Aragiorgis](https://github.com/dimara)

## TODO

* There's Always Something to Do
* Add more options (controller, port, etc.)


[vboxmanage_delete]: http://www.virtualbox.org/manual/ch08.html#vboxmanage-registervm "VBoxManage registervm / unregistervm"
