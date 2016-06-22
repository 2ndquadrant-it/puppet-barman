require 'spec_helper'

describe 'barman::server', :type => :define do

  let(:facts) do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :lsbdistid => 'Debian',
      :lsbdistcodename => 'squeeze',
      :ipaddress => '10.0.0.1',
    }
  end

  # Supply defaults for next tests
  before :all do
    @defaults = {
      :conninfo       => 'user=user1 host=server1 db=db1 pass=pass1 port=5432',
      :ssh_command    => 'ssh postgres@server1',
    }
  end

  # Example configuration
  let(:title) { 'server1' }
  let(:params) {
      @defaults
  }

  let :pre_condition do
    "class {'barman':}"
  end

  # Compiles template
  it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/\[server1\]/) }
  it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/conninfo = user=user1/) }
  it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/ssh_command = ssh postgres@server1/) }

  # Runs 'barman check' on the new server
  it { is_expected.to contain_exec('barman-check-server1').with_command('barman check server1 || true') }

  # Adds compression settings when asked
  context "without settings" do
    it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/compression = gzip/) }
    it { is_expected.not_to contain_file('/etc/barman.conf.d/server1.conf').with_content(/_backup_script/) }
  end
  # Does not add compression settings when not asked
  context "with settings" do
    let(:params) { @defaults.merge({ :compression => 'bzip2', :pre_backup_script => 'true', :post_backup_script => 'true', :custom_lines => 'thisisastring' }) }
    it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/compression = bzip2/) }
    it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/pre_backup_script = /) }
    it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/post_backup_script = /) }
    it { is_expected.to contain_file('/etc/barman.conf.d/server1.conf').with_content(/thisisastring/) }
  end

  # Fails with an invalid name
  context "with invalid name" do
    let(:title) { 'server!@#%' }
    it {
      expect{ is_expected.to contain_class('barman::server') }.to raise_error(Puppet::Error,/is not a valid name/)
    }
  end

  # Fails without conninfo and ssh_command
  context "without conninfo" do
    let(:params) { { :ssh_command => 'ssh postgres@server1' } }
    it {
      expect{ is_expected.to contain_class('barman::server') }.to raise_error(Puppet::Error,/(Must pass |expects a value for parameter ')conninfo/)
    }
  end
  context "without ssh_command" do
    let(:params) { { :conninfo => 'user=user1 host=server1 db=db1 pass=pass1 port=5432' } }
    it {
      expect{ is_expected.to contain_class('barman::server') }.to raise_error(Puppet::Error,/(Must pass |expects a value for parameter ')ssh_command/)
    }
  end

end
