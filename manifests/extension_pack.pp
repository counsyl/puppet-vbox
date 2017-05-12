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
#  "Oracle_VM_VirtualBox_Extension_Pack-4.3.28.vbox-extpack"
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
  case $ensure {
    'installed', 'present': {
      include sys
      include sys::expect

      # Download the extension pack into root's home directory.
      # TODO: This needs to be saved to a platform-dependent cache directory
      #  and not in root's home.
      $pack_path = "${sys::root_home}/${pack}"
      sys::fetch { 'extension-pack':
        source      => $source,
        destination => $pack_path,
      }

      # Install the Extension Pack with `VBoxManage`.
      $escaped_version = inline_template(
        "<%= scope['vbox::params::version'].gsub('.', '\\.') %>"
      )
      $extpack_install_cmd = "${vboxmanage} extpack install --replace ${pack}"
      file { '/tmp/extpack_expect_script':
        ensure => file,
        owner => 'root',
        group => 'root',
        source => 'puppet:///modules/vbox/extpack_expect_script',
      }
      exec { 'extension_pack-install':
        # Say yes to the license agreement using expect
        command => "/usr/bin/expect /tmp/extpack_expect_script $extpack_install_cmd",
        path    => ['/bin', '/usr/bin'],
        user    => 'root',
        cwd     => $sys::root_home,
        unless  => "${vboxmanage} list extpacks | grep -e '^Version:[[:space:]]*${escaped_version}$'",
        require => [Sys::Fetch['extension-pack'], Class['vbox', 'sys::expect']],
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
