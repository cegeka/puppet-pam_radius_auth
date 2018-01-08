#pam\_radius\_auth

[![Build Status](https://travis-ci.org/rji/puppet-pam_radius_auth.png?branch=master)](https://travis-ci.org/rji/puppet-pam\_radius\_auth)

Configures sshd and sudo PAM modules to use RADIUS for authentication.

##Overview:
Installs and configures pam\_radius\_auth module for PAM to allow
sshd and sudo to use RADIUS for authentication. As distributed,
this will also fallback to local authentication (using localifdown)
should the RADIUS servers be unavailable.

Although the distributed copy only supports Redhat/CentOS and
Debian/Ubuntu, this module should work, with minor modifications, on
any system that supports PAM:

1.  Add support for your distro/release in init.pp
2.  Add the following line _before_ system-auth:


        auth [success=done new_authtok_reqd=done ignore=ignore default=die] pam_radius_auth.so localifdown

This module has been tested on EL5, EL6 and EL7, as well as Ubuntu 12.04 LTS.


##Prerequisites:
On CentOS, the EPEL repo must be installed and enabled. Information on
the EPEL repo is available at: <http://fedoraproject.org/wiki/EPEL>


##Configuration:
Set the default servers, shared secret, and timeout in manifests/init.pp,
then include the class for your node(s):

    node 'prod.example.com' {
      include pam_radius_auth
    }

You may also override the defaults on a per-node basis:

    node 'test.example.com' {
      class { "pam_radius_auth":
        pam_radius_servers => [ "192.168.10.80",
                                "192.168.10.90" ],
        pam_radius_secret  => "sekrit",
        pam_radius_timeout => '5',
      }
    }


