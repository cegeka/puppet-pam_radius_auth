# This is the rji/pam_radius_auth module for Puppet.
# Written by Roger Ignazio <rignazio at gmail dot com>
#
# Configuration:
# $pam_radius_servers, $pam_radius_secret, and $pam_radius_timeout should
# be modified for your environment. The 'redhat-lsb' package will be installed
# to determine the OS major release.
#
# Compatibility:
# This module should also handle newer (or older) EL releases, or other distros,
# with slight modification (eg. putting the pam_radius_auth config in your
# system's relevant PAM file(s)). See GitHub or the README for more information.
#
class pam_radius_auth (
  $ensure                   = present,
  $pam_radius_servers       = undef,
  $pam_radius_secret        = undef,
  $pam_radius_timeout       = undef,
  $pam_radius_enforce       = 'permissive',
  $pam_radius_users_file    = 'pam_admin_users.conf',
  $pam_radius_authorized    = {},
) {

  include stdlib

  $pam_radius_servers_real  = $pam_radius_servers
  $pam_radius_secret_real   = $pam_radius_secret
  $pam_radius_timeout_real  = $pam_radius_timeout
  $pam_radius_enforce_real  = $pam_radius_enforce
  $pam_radius_users_file_real = $pam_radius_users_file

  validate_array($pam_radius_servers_real)
  #validate_re($pam_radius_secret_real, '^[~+._0-9a-zA-Z:-]+$')

  if ! is_integer($pam_radius_timeout_real) {
    fail("Pam_radius_auth[${name}]: pam_radius_timeout_real must be an integer")
  }

  validate_re($pam_radius_enforce_real, '^permissive$|^strict$')

  # Distribution check
  case $::operatingsystem {
    'RedHat','CentOS': {
      # Vars that apply to all Enterprise Linux releases
      $pkg  = 'pam_radius'
      $conf = '/etc/pam_radius.conf'

      $supported     = true
      $pam_sshd_conf = 'pam_sshd'
      $pam_sudo_conf = 'pam_sudo'

      if Integer($facts['os']['release']['major']) >= 8 {
        ensure_resource('package','sssd-client',{'ensure'=>$ensure})
      }
    }
    'Ubuntu', 'Debian': {
      # This module has been tested with Ubuntu 12.04 LTS.
      # Your experience may differ on older releases.
      $supported     = true
      $pkg           = 'libpam-radius-auth'
      $conf          = '/etc/pam_radius_auth.conf'
      $pam_sshd_conf = 'pam_sshd_deb'
      $pam_sudo_conf = 'pam_sudo_deb'
    }
    default: {
      $supported = false
      notify { "pam_radius_auth module not supported on OS ${::operatingsystem}":}
    }
  }

  # Environment checks passed, let's continue.
  if ($supported == true) {
    # Package installation
      # On Redhat/CentOS, pam_radius is in the EPEL repo
      # On Debian/Ubuntu, libpam-radius-auth is included in main
    package { $pkg:
      ensure  => $ensure,
    }

    file { $conf:
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('pam_radius_auth/pam_radius.conf.erb'),
      require => Package[$pkg],
    }

    # Copy sshd and sudo files to /etc/pam.d
    file { '/etc/pam.d/sshd':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("pam_radius_auth/${pam_sshd_conf}.erb"),
      require => [ Package[$pkg], File[$conf] ],
    }

    file { '/etc/pam.d/sudo':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("pam_radius_auth/${pam_sudo_conf}.erb"),
      require => [ Package[$pkg], File[$conf] ],
    }

    $pam_radius_authorized.each |$instance,$usernames| {
      $userlist = $usernames
      file { "/etc/pam_admin_users_${instance}.conf" :
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => template('pam_radius_auth/pam_admin_users.erb'),
        require => [ Package[$pkg], File[$conf] ],
      }
    }

  }
}
