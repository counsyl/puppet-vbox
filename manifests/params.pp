# == Class: vbox::params
#
# Platform-dependent parameters for VirtualBox.
#
class vbox::params {
  # The full version, and the major version (omits the subminor number).
  $version = '4.2.12'
  $major_version = inline_template("<%= @version.split('.')[0..1].join('.') %>")

  # The build number is necessary to to install on Mac.
  $build = '84980'

  # The source of the GPG key for the VirtualBox apt repository.
  $gpg_source = 'puppet:///modules/vbox/oracle_vbox.gpg'

  # The URL of the VirtualBox apt repository.
  $apt_url = 'http://download.virtualbox.org/virtualbox/debian/'

  case $::osfamily {
    darwin: {
      $package = "VirtualBox-${major_version}"
      $source  = "http://download.virtualbox.org/virtualbox/${version}/VirtualBox-${version}-${build}-OSX.dmg"
      $provider = 'pkgdmg'
    }
    debian: {
      $package = "virtualbox-${major_version}"
    }
    default: {
      fail("Do not know how to install VirtualBox on ${::osfamily}.\n")
    }
  }
}
