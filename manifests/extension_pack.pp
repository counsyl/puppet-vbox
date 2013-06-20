# == Class: vbox::extensions
#
# Installs the VirtualBox Extension Pack.
#
# === Parameters
#
# Parameters other than `ensure` are for advanced usage only, and you should not
# have to customize any of these values.
#
# [*source*]
#  The URL of the extension pack.
#
# [*pack*]
#  The base name of the VirtualBox extension pack, for example:
#  "Oracle_VM_VirtualBox_Extension_Pack-4.2.12-84980.vbox-extpack"
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

  # For downloading the extension pack, use curl on OS X and wget on
  # all other platforms.
  case $::osfamily {
    darwin: {
      $dl_cmd = 'curl --remote-name --location --silent'
      $dl_req = undef
    }
    default: {
      include sys::wget
      $dl_cmd = 'wget --quiet'
      $dl_req = Class['sys::wget']
    }
  }

  case $ensure {
    'installed', 'present': {
      # Download the extension pack into root's home directory.
      $pack_path = "${sys::root_home}/${pack}"
      exec { 'extension_pack-download':
        command => "${dl_cmd} ${source}",
        path    => ['/bin', '/usr/bin'],
        user    => 'root',
        cwd     => $sys::root_home,
        creates => $pack_path,
        require => $dl_req,
      }

      # Install the Extension Pack with `VBoxManage`.
      exec { 'extension_pack-install':
        command => "${vboxmanage} extpack install --replace ${pack}",
        path    => ['/bin', '/usr/bin'],
        user    => 'root',
        cwd     => $sys::root_home,
        creates => $directory,
        require => Class['vbox']
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
