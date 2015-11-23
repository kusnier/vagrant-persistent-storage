# Vagrant::Persistent-Storage


A Vagrant plugin that creates a persistent storage and attaches it to guest machine.

## Installation

    $ vagrant plugin install vagrant-persistent-storage

## Usage

After installing you can set the location and size of the persistent storage.

The following options will create a persistent storage with 5000 MB, named mysql,
mounted on /var/lib/mysql, in a volume group called 'vagrant'
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
A example which sets `prjquota` option with xfs.
```ruby
config.persistent_storage.mountname    = 'xfs'
config.persistent_storage.filesystem   = 'xfs'
config.persistent_storage.mountpoint   = '/mnt/xfs'
config.persistent_storage.mountoptions = ['defaults', 'prjquota']
```

Device defaults to /dev/sdb

Every `vagrant up` will attach this file as hard disk to the guest machine.
An `vagrant destroy` will detach the storage to avoid deletion of the storage by vagrant.
A `vagrant destroy` generally destroys all attached drives. See [VBoxMange unregistervm --delete option][vboxmanage_delete].

The disk is initialized and added to it's own volume group as specfied in the config; 
this defaults to 'vagrant'. An ext4 filesystem is created and the disk mounted appropriately,
with entries added to fstab ... subsequent runs will mount this disk with the options specified

## Windows Guests

Windows Guests must use the WinRM communicator by setting `vm.communicator = 'winrm'`.  An additional option is provided to 
allow you to set the drive letter using:

```
config.persistent_storage.drive_letter = 'Z'
```

Options that are irrelevent to Windows are ignored, such as `mountname`, `filesystem`, `mountpoint` and `volgroupname`.

## Troubleshooting

If your box are not using LVM you must set `config.persistent_storage.use_lvm = false`.

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

## TODO

* There's Always Something to Do
* Add more options (controller, port, etc.)


[vboxmanage_delete]: http://www.virtualbox.org/manual/ch08.html#vboxmanage-registervm "VBoxManage registervm / unregistervm"
