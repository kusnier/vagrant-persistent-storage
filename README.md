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

Device defaults to /dev/sdb

Every `vagrant up` will attach this file as hard disk to the guest machine.
An `vagrant destroy` will detach the storage to avoid deletion of the storage by vagrant.
A `vagrant destroy` generally destroys all attached drives. See [VBoxMange unregistervm --delete option][vboxmanage_delete].

The disk is initialized and added to it's own volume group as specfied in the config; 
this defaults to 'vagrant'. An ext4 filesystem is created and the disk mounted appropriately,
with entries added to fstab ... subsequent runs will mount this disk with the options specified

## Supported Providers

* Only the VirtualBox provider is supported.

## Contributors

* [madAndroid](https://github.com/madAndroid)
* [Jeremiah Snapp](https://github.com/jeremiahsnapp)
* [Hiroya Ito](https://github.com/hiboma)

## TODO

* There's Always Something to Do
* Add more options (controller, port, etc.)


[vboxmanage_delete]: http://www.virtualbox.org/manual/ch08.html#vboxmanage-registervm "VBoxManage registervm / unregistervm"
