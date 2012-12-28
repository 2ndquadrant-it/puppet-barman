require 'spec_helper'

describe 'barman' do

  let(:facts) { { 
    :osfamily => 'Debian',
    :lsbdistcodename => 'precise'
  } }

  # Enables PGDG for the running distribution
  it { should include_class('apt') }
  it { should contain_apt__source('apt-pgdg').with_release('precise-pgdg') }

  # Installs barman
  it { should contain_package('barman') }

  # Creates the configurations
  it { should contain_file('/etc/barman.conf.d') }
  it { should contain_file('/etc/logrotate.d/barman') }
  it { should contain_file('/etc/barman.conf').with_content(/\[barman\]/) }
  it { should contain_file('/etc/barman.conf').with_content(/compression = gzip/) }
  it { should_not contain_file('/etc/barman.conf').with_content(/_backup_script/) }
  
  # Creates barman home and launches 'barman check all'
  it { should contain_file('/var/lib/barman') }
  it { should contain_exec('barman-check-all') }

  # Creates the new home and launches barman check all
  context "with different home" do
    let(:params) { {
      :home  => '/srv/barman'
    } }

    it { should contain_file('/srv/barman').with_ensure('directory') } 
    it { should contain_exec('barman-check-all') }
  end

  # Rotates the right log when supplied
  context "with different log" do
    let(:params) { {
      :logfile  => '/tmp/foo'
    } }

    it { should contain_file('/etc/logrotate.d/barman').with_content(/^\/tmp\/foo /) } 
  end

  # Writes the right parameters in the compiled template
  context "with different parameters" do
    let(:params) { { 
      :compression => false,
      :pre_backup_script => '/bin/false',
      :post_backup_script => '/bin/false',
      :custom_lines => 'thisisastring'
    } }

    it { should_not contain_file('/etc/barman.conf').with_content(/compression/) } 
    it { should contain_file('/etc/barman.conf').with_content(/pre_backup_script = \/bin\/false/) } 
    it { should contain_file('/etc/barman.conf').with_content(/post_backup_script = \/bin\/false/) } 
    it { should contain_file('/etc/barman.conf').with_content(/thisisastring/) } 
  end
end
