# Strict Radius only authentication for admin users
class { 'pam_radius_auth':
  pam_radius_servers      => ['127.0.0.1'],
  pam_radius_secret       => 'somesecret',
  pam_radius_timeout      => 2,
  pam_radius_enforce      => 'strict',
  pam_radius_admin_users  => ['johndoe','mistermac']
}
