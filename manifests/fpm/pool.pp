# Set up a PHP-FPM pool listening on a socket
#
# Automatically ensures that the version of PHP is installed and
# PHP-FPM is installed as a service for that version
#
# Usage:
#
#     php::fpm::pool { '5.4.10 for my project':
#       version     => '5.4.10',
#       socket_path => '/path/to/socket'
#     }
#
define php::fpm::pool(
  $version,
  $socket_path,
  $pm                = 'dynamic',
  $max_children      = 2,
  $start_servers     = 1,
  $min_spare_servers = 1,
  $max_spare_servers = 1,
  $ensure            = present,
  $fpm_pool          = 'php/php-fpm-pool.conf.erb',
) {
  require php::config

  # Current supported and secure versions
  $secure_5_6 = $php::config::secure_versions['5.6']
  $secure_5_5 = $php::config::secure_versions['5.5']
  $secure_5_4 = $php::config::secure_versions['5.4']

  # Specify secure version if no minor point specified
  if $version == '5' {
    $patch_version = $secure_5_6
  } elsif $version == '5.6' {
    $patch_version = $secure_5_6
  } elsif $version == '5.5' {
    $patch_version = $secure_5_5
  } elsif $version == '5.4' {
    $patch_version = $secure_5_4
  } else {
    $patch_version = $version
  }

  # Set config

  $fpm_pool_config_dir = "${php::config::configdir}/${patch_version}/pool.d"
  $pool_name = join(split($name, '[. ]'), '_')

  # Set up PHP-FPM pool

  if $ensure == present {
    # Ensure that the php fpm service for this php version is installed
    # eg. php::fpm::5_4_10
    php_fpm_require $patch_version

    # Create a pool config file
    file { "${fpm_pool_config_dir}/${pool_name}.conf":
      content => template($fpm_pool),
      require => File[$fpm_pool_config_dir],
      notify  => Service["dev.php-fpm.${patch_version}"],
    }
  }
}
