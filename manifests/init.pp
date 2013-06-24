# == Class: vbox
#
# Installs the VirtualBox virtualization software.
#
# === Parameters
#
# [*ensure*]
#  The ensure value for the VirtualBox package resource.  Defaults
#  to 'installed'.
#
# [*package*]
#  The name of the package to install, default depends on the platform
#  and VirtualBox version.
#
# [*provider*]
#  Provider for the VirtualBox package resource, default is platform-dependent.
#
# [*source*]
#  Source for the VirtualBox resource, default is platform-dependent.
#
# [*apt_url*]
#  Debian-specific parameter for specifying the URL to the apt package
#  repository source.
#
# [*gpg_source*]
#  Debian-specific parameter for specifying source file for VirtualBox
#  GPG apt-key.  Default is 'puppet:///modules/vbox/oracle_vbox.gpg'.
#
class vbox(
  $ensure     = 'installed',
  $package    = $vbox::params::package,
  $provider   = $vbox::params::provider,
  $source     = $vbox::params::source,
  $apt_url    = $vbox::params::apt_url,
  $gpg_source = $vbox::params::gpg_source,
) inherits vbox::params {

  case $::osfamily {
    debian: {
      # On debian, we're going to have to setup Oracle's VirtualBox
      # repository first before installing the package.
      include apt
      include apt::update

      # Have Oracle's GPG key in place, and construct an apt sources list
      # specific for VirtualBox.
      apt::key { $gpg_source: }

      $sources = "${apt::sources_d}/oracle_vbox.list"
      $repositories = [
        {'uri'          => $apt_url,
         'distribution' => $::lsbdistcodename,
         'components'   => ['contrib'],
        }
      ]

      apt::sources { $sources:
        repositories => $repositories,
        source       => false,
        notify       => Class['apt::update'],
        require      => Apt::Key[$gpg_source],
      }

      # Anchoring `apt::update` into this class to guarantee the apt-update
      # occurs prior to installing the package.
      anchor { 'vbox::apt':
        require => Class['apt::update'],
      }

      # Dynamic Kernel Module Support package is needed so that kernel upgrades
      # won't break VirtualBox.
      include sys::dkms
      $package_require = [Anchor['vbox::apt'], Class['sys::dkms']]
    }
    default: {
      $package_require = undef
    }
  }

  # The VirtualBox package resource.
  package { $package:
    ensure   => $ensure,
    source   => $source,
    provider => $provider,
    require  => $package_require,
  }
}
