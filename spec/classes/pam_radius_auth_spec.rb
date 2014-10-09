#!/usr/bin/env rspec

require 'spec_helper'

describe 'pam_radius_auth' do
  it { should contain_class 'pam_radius_auth' }
end
