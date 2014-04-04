# == Class: vbox::params
#
# Platform-dependent parameters for VirtualBox.
#
class vbox::params {
  # The full version, and the major version (omits the subminor number).
  $version = hiera('vbox::version', '4.3.10')
  $major_version = inline_template("<%= @version.split('.')[0..1].join('.') %>")

  # The build number is necessary to construct proper URLs.
  $build = hiera('vbox::build', '93012')

  # The source of the GPG key for the VirtualBox apt repository.
  $gpg_source = 'puppet:///modules/vbox/oracle_vbox.gpg'

  # The URL of the VirtualBox apt repository.
  $apt_url = 'http://download.virtualbox.org/virtualbox/debian/'

  # The base URL to download VirtualBox packages and extension packs.
  $download_url = "http://download.virtualbox.org/virtualbox/${version}"

  # Parameters for the Extension Pack.
  $extension_pack = "Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack"
  $extension_pack_url = "${download_url}/${extension_pack}"

  case $::osfamily {
    darwin: {
      $package = "VirtualBox-${version}"
      $dmg = "VirtualBox-${version}-${build}-OSX.dmg"
      $source  = "${download_url}/${dmg}"
      $provider = 'pkgdmg'
      $extension_pack_dir = '/Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack'
    }
    debian: {
      $package = "virtualbox-${major_version}"
      $extension_pack_dir = '/usr/lib/virtualbox/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack'
    }
    default: {
      fail("Do not know how to install VirtualBox on ${::osfamily}.\n")
    }
  }

  # Path to VBoxManage.
  $vboxmanage = '/usr/bin/VBoxManage'
}
