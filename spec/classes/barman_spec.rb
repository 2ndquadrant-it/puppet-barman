require 'spec_helper'

describe 'barman' do

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

  # Installs barman
  it { is_expected.to contain_package('barman').with_tag('postgresql') }

  # Creates the configurations
  it { is_expected.to contain_file('/etc/barman.conf.d') }
  it { is_expected.to contain_file('/etc/logrotate.d/barman') }
  it { is_expected.to contain_file('/etc/barman.conf').with_content(/\[barman\]/) }
  it { is_expected.to contain_file('/etc/barman.conf').with_content(/compression = gzip/) }
  it { is_expected.not_to contain_file('/etc/barman.conf').with_content(/_backup_script/) }

  # Creates barman home and launches 'barman check all'
  it { is_expected.to contain_file('/var/lib/barman') }
  it { is_expected.to contain_exec('barman-check-all') }

  # Creates the new home and launches barman check all
  context "with different home" do
    let(:params) do
      {
        :home  => '/srv/barman',
      }
    end

    it { is_expected.to contain_file('/srv/barman').with_ensure('directory') }
    it { is_expected.to contain_exec('barman-check-all') }
  end

  # Rotates the right log when supplied
  context "with different log" do
    let(:params) do
      {
        :logfile  => '/tmp/foo'
      }
    end

    it { is_expected.to contain_file('/etc/logrotate.d/barman').with_content(/^\/tmp\/foo /) }
  end

  # Writes the right parameters in the compiled template
  context "with different parameters" do
    let(:params) do
      {
      :compression => false,
      :pre_backup_script => '/bin/false',
      :post_backup_script => '/bin/false',
      :custom_lines => 'thisisastring'
      }
    end

    it { is_expected.not_to contain_file('/etc/barman.conf').with_content(/compression/) }
    it { is_expected.to contain_file('/etc/barman.conf').with_content(/pre_backup_script = \/bin\/false/) }
    it { is_expected.to contain_file('/etc/barman.conf').with_content(/post_backup_script = \/bin\/false/) }
    it { is_expected.to contain_file('/etc/barman.conf').with_content(/thisisastring/) }
  end

  # Test interaction between manage_package_repo parameter and postgresql::global
  context "with postgresql::globals already defined" do

    let :pre_condition do
      <<-HERE
        class {'postgresql::globals':
          manage_package_repo => true,
        }
      HERE
    end

    context "with manage_package_repo => true" do
      let(:params) do
        {
          :manage_package_repo  => true
        }
      end

      it { is_expected.to raise_error(Puppet::Error, /postgresql::globals is already defined/) }
    end

    context "with manage_package_repo => false" do
      let(:params) do
        {
          :manage_package_repo  => false
        }
      end

      it { is_expected.to compile }
    end

  end

end
