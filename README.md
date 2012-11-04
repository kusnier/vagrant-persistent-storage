# Vagrant::Persistent-Storage


A Vagrant plugin that creates a persistent storage and attaches it to guest machine.

## Installation

    gem 'vagrant-persistent-storage'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vagrant-persistent-storage

## Usage

After installing you can set the location and size of the persistent storage.

The following options will create a persistent storage with 5000 MB:
```ruby
config.persistent_storage.location = "~/development/sourcehdd.vdi"
config.persistent_storage.size = 5000
```

Every `vagrant up` will attach this file as hard disk to the guest machine.
An `vagrant destory` will detach the storage to avoid deletion of the storage by vagrant.
A `vagrant destory` generally destroys all attached drives. See [VBoxMange unregistervm --delete option][vboxmanage_delete].

### How to initialize the tisk with puppt

This is a sample puppet setup to create a partition on the guest system:

```puppet
class sources::persistent {
  exec { "fdisk-sourcehd":
    command => "/sbin/fdisk /dev/sdb << EOF
o
n
p
1


w
EOF",
    unless => "/bin/grep sdb1 /proc/partitions",
  }

  exec { "mkfs-sourcehd":
    command     => "/sbin/mkfs.ext3 -L sources -b 4096 /dev/sdb1",
    unless      => "/sbin/dumpe2fs /dev/sdb1"
  }
  
  exec { 'fstab-sourcehd':
    command => '/bin/echo "/dev/disk/by-label/sources /mnt/sources ext3 defaults 0 2" >> /etc/fstab',
    unless  => '/bin/grep ^/dev/disk/by-label/sources /etc/fstab',
  }
  
  exec { 'mount-sourcehd':
    command     => '/bin/mkdir -p /mnt/sources; /bin/mount /mnt/sources',
    subscribe   => Exec['fstab-sourcehd'],
    refreshonly => true,
  }

  Exec['fdisk-sourcehd'] -> Exec['mkfs-sourcehd'] -> Exec['fstab-sourcehd'] -> Exec['mount-sourcehd']
}
```

## TODO

* There's Always Something to Do
* Add more options (controller, port, etc.)


[vboxmanage_delete]: http://www.virtualbox.org/manual/ch08.html#vboxmanage-registervm "VBoxManage registervm / unregistervm"
