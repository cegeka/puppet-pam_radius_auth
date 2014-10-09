#!/usr/bin/env rspec

require 'spec_helper'

describe 'pam_radius_auth' do
  let(:params) { { :pam_radius_servers => ['127.0.0.1'] , :pam_radius_secret => 'sekrit' , :pam_radius_timeout => 1 } }
  it { should contain_class 'pam_radius_auth' }
end
