# == Class: vbox::timesync
#
# This class makes it possible to disable VirtualBox time synchronization in a
# virtual machine running VirtualBox guest extensions.  While it's best to do
# this at the host-level, this class makes it possible to do inside the guest
# by modifying the guest extension service script (currently only supported on
# Debian guests).
#
# === Parameters
#
# [*ensure*]
#  The ensure value for this class; 'enabled' or 'present' enables host time
#  synchronization and 'absent' or 'disabled' disable it.
#
class vbox::timesync(
  $ensure = 'enabled',
) {
  validate_re($ensure, '^(absent|disabled|enabled|present)$')

  case $::osfamily {
    'Debian': {
      # The presence or absence of the `--disable-timesync` option
      # in the service script determines whether sync is enabled.
      $with_timesync = '        daemon \$binary > \/dev\/null'
      $without_timesync = '        daemon \$binary --disable-timesync > \/dev\/null'
      $vboxadd_service_conf = '/etc/init.d/vboxadd-service'

      if $ensure in ['absent', 'disabled'] {
        $command = "/bin/sed -i \"s/^${with_timesync}\$/${without_timesync}/\" ${vboxadd_service_conf}"
        $onlyif = "/bin/grep '^${with_timesync}$' ${vboxadd_service_conf}"
      } else {
        $command = "/bin/sed -i \"s/^${without_timesync}\$/${with_timesync}/\" ${vboxadd_service_conf}"
        $onlyif = "/bin/grep '^${without_timesync}$' ${vboxadd_service_conf}"
      }

      exec { 'vboxadd-timesync':
        command => $command,
        onlyif  => $onlyif,
      }

      exec { 'vboxadd-service-restart':
        command     => '/etc/init.d/vboxadd-service restart',
        refreshonly => true,
        subscribe   => Exec['vboxadd-timesync'],
      }
    }
    default: {
      fail("Do not know how to manage VirtualBox time synchronization on ${::osfamily}.")
    }
  }
}
