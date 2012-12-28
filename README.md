# BaRMan module for Puppet

## Description

This module manages the installation of BaRMan and the configuration of postgres servers to be backed up.

## Usage

### barman

The barman class installs barman. Currently only Ubuntu is supported.

    class { barman:
      home     => '/srv/barman',
      logfile  => '/var/log/barman/something_else.log',
      compression => 'bzip2',
      pre_backup_script = '/usr/bin/touch /tmp/started',
      post_backup_script = '/usr/bin/touch /tmp/stopped',
      custom_lines = '; something'
    }

All parameters are optional.

### barman::server

Configures a server to be backed up with barman.

    barman::server { 'main':
      conninfo    => 'user=postgres host=server1 password=pg123',
      ssh_command => 'ssh postgres@server1',
      compression => 'bzip2',
      pre_backup_script = '/usr/bin/touch /tmp/started',
      post_backup_script = '/usr/bin/touch /tmp/stopped',
      custom_lines = '; something'
    }

Only conninfo and ssh_command are required.

## License

This module is distributed under GNU GPLv3

## Author

This module was developed by Alessandro Grassi for Devise.IT.

