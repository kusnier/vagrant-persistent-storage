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

## TODO

* There's Always Something to Do


[vboxmanage_delete]: http://www.virtualbox.org/manual/ch08.html#vboxmanage-registervm "VBoxManage registervm / unregistervm"
