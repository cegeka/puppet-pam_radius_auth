require 'spec_helper'

describe 'pam_radius_auth' do
  let(:facts)  { { :operatingsystem   => 'CentOS',
                   :lsbmajdistrelease => '6' } }
  let(:params) { { :pam_radius_servers => ['192.168.10.80', '192.168.10.90' ],
                   :pam_radius_secret  => 'sekrit',
                   :pam_radius_timeout => '5' } }

  # pam_radius.conf servers, secrets, and timeouts
  it do
    should contain_file('/etc/pam_radius.conf')\
      .with_content(/^192\.168\.10\.80\s*sekrit\s*5/)
  end

  it do
    should contain_file('/etc/pam_radius.conf')\
      .with_content(/^192\.168\.10\.90\s*sekrit\s*5/)
  end

  # pam_radius.conf
  it do
    should contain_file('/etc/pam_radius.conf').with({
      'ensure' => 'present',
      'mode'   => '0600',
      'owner'  => 'root',
      'group'  => 'root'
    })
  end

  # SSHd PAM file
  it { should contain_file('/etc/pam.d/sshd') }

  # Sudo PAM file
  it { should contain_file('/etc/pam.d/sudo') }

end
