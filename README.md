# Barman module for Puppet

## Description

This module manages the installation of Barman and the configuration of PostgreSQL servers to be backed up.

For further information on barman:

* [Project homepage](http://www.pgbarman.org)
* [Barman documentation](http://docs.pgbarman.org)

## Installation

The module can be installed automatically with the *puppet* command on the master, or manually by cloning the
repository in your puppet module path.

### Installing via puppet

The latest version of the module can be installed automatically by supplying the repository information to
the module installer:

    # puppet module install deviseit-barman

This will take care of the dependencies as well.

### Installing manually

If you choose to install manually, you will have to clone the repository in the module path.

## Usage

### barman

The barman class installs barman. Currently only Ubuntu and Debian are supported.

Intensive testing has only been done on Ubuntu 12.04 LTS.

In order to install Barman with the defaults option, it is sufficient to just include the
barman class:

    class { 'barman': }

The package of latest version of barman is always available in PGDG
[apt](http://apt.postgresql.org/) and
[yum](http://yum.postgresql.org/) repository.
If you want to setup it for your installation the easiest way is to
use the
[postgresql](https://github.com/puppetlabs/puppetlabs-postgresql)
module.

    class { 'postgresql::globals':
      manage_package_repo => true,
    }->
    class { 'barman': }

All the configuration options that barman accepts can be overridden from the package defaults.

Example usage:

    class { barman:
      home     => '/srv/barman',
      logfile  => '/var/log/barman/something_else.log',
      compression => 'bzip2',
      pre_backup_script = '/usr/bin/touch /tmp/started',
      post_backup_script = '/usr/bin/touch /tmp/stopped',
      custom_lines = '; something'
    }

#### Parameters

* **home** - A different place for backups than the default. Will be symlinked
             to the default (/var/lib/barman).
            You should not change this value after the first setup.
* **logfile** - A different log file. Default: /var/log/barman/barman.log
* **compression** - Compression algorithm. Currently supports 'gzip' (default),
                   'bzip2', and 'custom'. Disabled if false.
* **pre_backup_script** - Script to launch before backups.
                        Disabled if false (default).
* **post_backup_script** - Script to launch after backups.
                        Disabled if false (default).
* **custom_lines** - Custom configuration directives (e.g. for custom
                     compression). Defaults to empty.

#### Facts

 The module generates a fact called **barman_key** which has the content of
  **/var/lib/barman/.ssh/id_rsa.pub**, in order to automatically handle the
  key exchange on the postgres server via puppetdb.

 If the file doesn't exist, a key will be generated.

### barman::server

The barman::server class configures barman to handle backups for a PostgreSQL server.

The only required parameters are **conninfo** and **ssh_command**.

Example:

    barman::server { 'main':
      conninfo    => 'user=postgres host=server1 password=pg123',
      ssh_command => 'ssh postgres@server1',
    }

Overriding global configuration is supported for most of the parameters.

Example:

    barman::server { 'main':
      conninfo    => 'user=postgres host=server1 password=pg123',
      ssh_command => 'ssh postgres@server1',
      compression => 'bzip2',
      pre_backup_script = '/usr/bin/touch /tmp/started',
      post_backup_script = '/usr/bin/touch /tmp/stopped',
      custom_lines = '; something'
    }

#### Parameters

Many of the main configuration parameters can be passed in order to
 perform overrides.

* **conninfo** - Postgres connection string. **Mandatory**.
* **ssh_command** - Command to open an ssh connection to Postgres. **Mandatory**.
* **compression** - Compression algorithm. Uses the global configuration
                   if false (default).
* **pre_backup_script** - Script to launch before backups. Uses the global
                          configuration if false (default).
* **post_backup_script** - Script to launch after backups. Uses the global
                          configuration if false (default).
* **custom_lines** - Custom configuration directives (e.g. for custom
                     compression). Defaults to empty.
 
## License

This module is distributed under GNU GPLv3

## Author

This module was developed by Alessandro Grassi for Devise.IT.
  Special thanks go to the 2ndQuadrant Italia team.

