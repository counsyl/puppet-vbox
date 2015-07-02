vbox
====

This Puppet module is for installing and configuring [VirtualBox](https://www.virtualbox.org/), the open source virtualization platform.

Classes
-------

### `vbox`

This class installs VirtualBox for the platform.  To use, simply include this class:

```puppet
include vbox
```

### `vbox::extension_pack`

Installs Oracle's VirtualBox [Etension Pack](https://www.virtualbox.org/manual/ch01.html#intro-installing), the commercial extension that provides advanced features for USB 2.0 and VRDP support.  To use, simply include the class after [`vbox`](#vbox):

```puppet
include vbox
include vbox::extension_pack
```

### `vbox::timesync`

Allows managing of host time synchronization on VirtualBox guests (only supports Debian at this time).  The following example disables time sync:

```puppet
class { 'vbox::timesync':
  ensure => 'disabled',
}
```

License
-------

Apache License, Version 2.0

Contact
-------

Justin Bronn <justin@counsyl.com>

Support
-------

Please log tickets and issues at https://github.com/counsyl/puppet-vbox
