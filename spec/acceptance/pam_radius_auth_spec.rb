require 'spec_helper_acceptance'

describe 'pam_radius_auth::init' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS

        include 'yum'
        include 'profile::package_management'
        include stdlib::stages
        class { 'cegekarepos' : stage => 'setup_repo' }

        Yum::Repo <| title == 'epel' |>


        class { 'pam_radius_auth':
          pam_radius_servers      => ['127.0.0.1'],
          pam_radius_secret       => 'somese0cret',
          pam_radius_timeout      => 2,
          pam_radius_admin_users  => ['johndoe']
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/pam_radius.conf' do
      it { is_expected.to be_file }
      its(:content) { should match /somese0cret/ }
      its(:content) { should match /127.0.0.1/ }
    end
    describe file '/etc/pam_admin_users.conf' do
      it { is_expected.to be_file }
      its(:content) { should match /johndoe/ }
    end
  end
end
