# Public: specify the global php version for phpenv
#
# Usage:
#
#   class { 'php::global': version => '5.4.10' }
#
class php::global($version = undef) {
  include php::config

  # Current supported and secure versions
  $secure_5_6 = $php::config::secure_versions['5.6']
  $secure_5_5 = $php::config::secure_versions['5.5']
  $secure_5_4 = $php::config::secure_versions['5.4']

  # Specify secure version if no minor point specified
  if $version == '5' {
    $php_version = $secure_5_6
  } elsif $version == '5.6' {
    $php_version = $secure_5_6
  } elsif $version == '5.5' {
    $php_version = $secure_5_5
  } elsif $version == '5.4' {
    $php_version = $secure_5_4
  } else {
    $php_version = $version
  }

  if $version != 'system' {
    php_require($php_version)
  }

  file { "${php::config::root}/version":
    ensure  => present,
    owner   => $::boxen_user,
    mode    => '0644',
    content => "${php_version}\n",
  }
}
