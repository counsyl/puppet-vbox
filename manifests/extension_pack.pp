# == Class: vbox::extensions
#
# Installs Oracle's VirtualBox Extension Pack.
#
# === Parameters
#
# Parameters other than `ensure` are for advanced usage only, you shouldn't
# have to customize these values.
#
# [*ensure*]
#  Whether or not to install the extension pack, defaults to 'present'
#  When set to 'absent', ensures removal of the extension pack.
#
# [*source*]
#  The URL of the extension pack.
#
# [*pack*]
#  The base name of the VirtualBox extension pack, for example:
#  "Oracle_VM_VirtualBox_Extension_Pack-4.2.12.vbox-extpack"
#
# [*directory*]
#  The directory created when the VirtualBox extension pack is installed,
#  default is platform-dependent.
#
# [*vboxmanage*]
#  The path to the VBoxManage command, defaults to '/usr/bin/VBoxManage'.
#
class vbox::extension_pack(
  $ensure     = 'present',
  $source     = $vbox::params::extension_pack_url,
  $pack       = $vbox::params::extension_pack,
  $directory  = $vbox::params::extension_pack_dir,
  $vboxmanage = $vbox::params::vboxmanage,
) inherits vbox::params {
  include sys

  case $ensure {
    'installed', 'present': {
      # Download the extension pack into root's home directory.
      $pack_path = "${sys::root_home}/${pack}"
      sys::fetch { 'extension-pack':
        source      => $source,
        destination => $pack_path,
      }

      # Install the Extension Pack with `VBoxManage`.
      exec { 'extension_pack-install':
        command => "${vboxmanage} extpack install --replace ${pack}",
        path    => ['/bin', '/usr/bin'],
        user    => 'root',
        cwd     => $sys::root_home,
        creates => $directory,
        require => [Sys::Fetch['extension-pack'], Class['vbox']],
      }
    }
    'absent': {
      exec { 'extension_pack-uninstall':
        command => "${vboxmanage} extpack uninstall 'Oracle VM VirtualBox Extension Pack'",
        path    => ['/bin', '/usr/bin'],
        user    => 'root',
        unless  => "test ! -d ${directory}",
        require => Class['vbox']
      }
    }
    default: {
      fail("Invalid ensure value for vbox::extension_pack: ${ensure}\n")
    }
  }
}
