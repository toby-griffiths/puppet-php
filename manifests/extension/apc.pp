# Installs a php extension for a specific version of php.
#
# Usage:
#
#     php::extension::apc { 'apc for 5.4.10':
#       php     => '5.4.10',
#       version => '3.1.13'
#     }
#
define php::extension::apc(
  $php,
  $version = '3.1.13'
) {
  require php::config

  # Current supported and secure versions
  $secure_5_6 = $php::config::secure_versions['5.6']
  $secure_5_5 = $php::config::secure_versions['5.5']
  $secure_5_4 = $php::config::secure_versions['5.4']

  # Specify secure version if no minor point specified
  if $php == '5' {
    $patch_version = $secure_5_6
  } elsif $php == '5.6' {
    $patch_version = $secure_5_6
  } elsif $php == '5.5' {
    $patch_version = $secure_5_5
  } elsif $php == '5.4' {
    $patch_version = $secure_5_4
  } else {
    $patch_version = $php
  }

  # Require php version eg. php::5_4_10
  # This will compile, install and set up config dirs if not present
  php_require($patch_version)

  if ($patch_version == '5.4') {
    $extension = 'apc'
    $package_name = "APC-${version}"
    $url = "http://pecl.php.net/get/APC-${version}.tgz"
  } else {
    $extension = 'apcu'
    $package_name = "APCu-${version}"
    $url = "http://pecl.php.net/get/apcu-${version}.tgz"
  }

  # Final module install path
  $module_path = "${php::config::root}/versions/${patch_version}/modules/${extension}.so"

  php_extension { $name:
    extension      => $extension,
    version        => $version,
    package_name   => $package_name,
    package_url    => $url,
    homebrew_path  => $boxen::config::homebrewdir,
    phpenv_root    => $php::config::root,
    php_version    => $patch_version,
    cache_dir      => $php::config::extensioncachedir,
  }

  # Add config file once extension is installed

  file { "${php::config::configdir}/${patch_version}/conf.d/${extension}.ini":
    content => template("php/extensions/apc.ini.erb"),
    require => Php_extension[$name],
  }

}
