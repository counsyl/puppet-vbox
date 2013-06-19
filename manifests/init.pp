# == Class: vbox
#
# Installs the VirtualBox virtualization software.
#
class vbox(
  $ensure     = 'installed',
  $packge     = $vbox::params::package,
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

      $sources = "${apt::sources_d}/oracle_vbox.list"
      $repositories = [
        {'uri'          => $apt_url,
         'distribution' => $::lsbdistcodename,
         'components'   => ['contrib'],
        }
      ]

      apt::key { $gpg_source: }

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
