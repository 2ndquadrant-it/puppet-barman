[![Build Status](https://travis-ci.org/2ndquadrant-it/puppet-barman.svg?branch=master)](https://travis-ci.org/2ndquadrant-it/puppet-barman)

# Barman module for Puppet

## Description

This module manages the installation of Barman and the configuration of
PostgreSQL servers to be backed up.

For further information on Barman:

* [Project homepage](http://www.pgbarman.org)
* [Barman documentation](http://docs.pgbarman.org)

## Installation

The module can be installed automatically with the *puppet* command on the
master, or manually by cloning the repository in your puppet module path.

### Installing via puppet

The latest version of the module can be installed automatically by supplying
the repository information to the module installer:

    # puppet module install it2ndq-barman

This will take care of the dependencies as well.

### Installing manually

If you choose to install manually, you will have to clone the repository in the
module path.

## Usage

### barman

The `barman` class installs Barman. Currently only Ubuntu and Debian are
supported.

Intensive testing has only been done on Ubuntu 12.04 LTS.

In order to install Barman with the default options, it is sufficient to just
include the barman class:

    class { 'barman': }

The package of latest version of Barman is always available in PGDG
[apt](http://apt.postgresql.org/) and
[yum](http://yum.postgresql.org/) repository.
If you want to setup it for your installation, the easiest way is to
use the
[postgresql](https://github.com/puppetlabs/puppetlabs-postgresql)
module.

    class { 'postgresql::globals':
      manage_package_repo => true,
    }->
    class { 'barman': }

**Note:** In versions of `it2ndq/barman' > 2.1, setup of PGDG
repository can be done automatically by setting the
`manage_package_repo` parameter to to `true`. It will be implemented
internally by declaring the `postgresql::globals` class. If you need
to customize the `postgresql::globals` class declaration, keep the
`manage_package_repo` parameter disabled in `barman` module and enable
it directly in `postgresql::globals` class.

All the configuration options that Barman accepts can be defined through Puppet.

Example usage:

    class { barman:
      logfile            => '/var/log/barman/something_else.log',
      compression        => 'bzip2',
      pre_backup_script  => '/usr/bin/touch /tmp/started',
      post_backup_script => '/usr/bin/touch /tmp/stopped',
    }

#### Parameters

Parameters can be set in three places:

* **barman::settings** - set the default values for the manifest.
* **barman** - set the global values for the Barman server.
* **barman::server** - set the per PostgreSQL server values.

These are the available parameters for the `barman` class

* **user** - The Barman user. Defaults to `barman::settings::user`.
* **group** - The group of the Barman user. Defaults to
              `barman::settings::group`.
* **ensure** - Ensure that Barman is installed. The default value is `present`.
* **conf_template** - Path of the template for the `barman.conf` configuration
                      file. You may change this value to use a custom template.
* **logrotate_template** - Path of the template for the `logrotate.conf` file.
                           You may change this value to use a custom template.
* **home** - A different location for backups than the default. Will be
            symlinked to the default (`/var/lib/barman`). You should not change
            this value after the first setup. Defaults to
            `barman::settings::home`.
* **logfile** - A different log file. The default is
                `barman::settings::logfile`.
* **compression** - Compression algorithm. Currently supports `gzip`, `bzip2`,
                    and `custom`. Defaults to `barman::settings:compression`.
* **immediate_checkpoint** -  Force the checkpoint on the Postgres server to
                              happen immediately and start your backup copy
                              process as soon as possible. Disabled if false.
                              Defaults to
                              `barman::settings::immediate_checkpoint`
* **pre_backup_script** - Script to run before backups. Disabled if false.
                          Defaults to `barman::settings::pre_backup_script`.
* **post_backup_script** - Script to run after backups. Disabled if false.
                           Defaults to `barman::settings::post_backup_script`.
* **pre_archive_script** - Script to run before a WAL file is archived by
                           maintenance. Disabled if false.
                           Defaults to `barman::settings::pre_archive_script`.
* **post_archive_script** - Script to run after a WAL file is archived by
                            maintenance. Disabled if false.
                            Defaults to `barman::settings::post_archive_script`.
* **basebackup_retry_times** - Number of retries for data copy during base
                               backup after an error. Defaults to
                               `barman::settings::basebackup_retry_times`
* **basebackup_retry_sleep** - Number of seconds to wait after a failed
                               copy, before retrying. Defaults to
                               `barman::settings::basebackup_retry_sleep`
* **backup_options** - Behaviour for backup operations: possible values are
                       `exclusive_backup` and `concurrent_backup`. Defaults to
                      `barman::settings::backup_options`.
* **minimum_redundancy** - Minimum number of required backups (redundancy).
                           Defaults to `barman::settings::minimum_redundancy`.
* **last_backup_maximum_age** - Time frame in which the latest backup date must
                                be contained. If the latest backup is older
                                than the time frame, `barman check` command
                                will report an error to the user. Empty if
                                false. Defaults to
                                `barman::settings::last_backup_maximum_age`.
* **retention_policy** - Base backup retention policy, based on redundancy or
                         recovery window. Value must be greater than or equal
                         to the server minimum redundancy level. If this
                         condition is not satistied, the minimum redundancy
                         value is assigned to this parameter. Defaults to
                         `barman::settings::retention_policy`.
* **wal_retention_policy** - WAL archive logs retention policy. Currently, the
                             only allowed value for `wal_retention_policy` is
                             the special value `main`, that maps the retention
                             policy of archive logs to that of base backups.
                             Defaults to
                             `barman::settings::wal_retention_policy`.
* **retention_policy_mode** - Can only be set to `auto` (retention policies are
                              automatically enforced by the `barman cron`
                              command). Defaults to
                              `barman::settings::retention_policy_mode`.
* **reuse_backup** - Incremental backup is a kind of full periodic backup which
                     saves only data changes from the latest full backup
                     available in the catalogue for a specific PostgreSQL
                     server. Disabled if false. Available values are
                     `off`, `link` and `copy`. Defaults to
                     `barman::settings::reuse_backup`.
* **custom_lines** - DEPRECATED. Custom configuration directives (e.g. for
                     custom compression). Defaults to
                     `barman::settings::custom_lines`.
* **barman_fqdn** - The fully qualified domain name of the Barman server. It is
                    exported in several resources in the PostgreSQL server.
                    Puppet automatically set this.
* **autoconfigure** - This is the main parameter to enable the autoconfiguration
                     of the backup of a given PostgreSQL server.
                     Defaults to `barman::settings::autoconfigure`.
* **exported_ipaddress** - The ipaddress exported to the PostgreSQL server
                           during atutoconfiguration. Defaults to
                           `${::ipaddress}/32`.
* **host_group** -  Tag used to collect and export resources during
                    autoconfiguration. Defaults to `global`.
* **manage_package_repo** - Configure PGDG repository. It is implemented
                            internally by declaring the `postgresql::globals`
                            class. If you need to customize the
                            `postgresql::globals` class declaration, keep the
                            `manage_package_repo` parameter disabled in `barman`
                            module and enable it directly in
                            `postgresql::globals` class.

See the file **init.pp** for more details.

#### Facts

The module generates a fact called **barman_key** which has the content of
**/var/lib/barman/.ssh/id_rsa.pub**, in order to automatically handle the
key exchange on the Postgres server via puppetdb.

If the file doesn't exist, a key will be generated.

### barman::settings

The `barman::settings` class holds the default configuration parameters to set up
a Barman server through Puppet.

See the file **settings.pp** for more details.

### barman::server

The `barman::server` class sets the per server Barman configuration parameters.

The only required parameters are **conninfo** and **ssh_command**.

Example:

    barman::server { 'main':
      conninfo    => 'user=postgres host=server1 password=pg123',
      ssh_command => 'ssh postgres@server1',
    }

Overriding global configuration is supported for most of the parameters.

Example:

    barman::server { 'main':
      conninfo           => 'user=postgres host=server1 password=pg123',
      ssh_command        => 'ssh postgres@server1',
      compression        => 'bzip2',
      pre_backup_script  => '/usr/bin/touch /tmp/started',
      post_backup_script => '/usr/bin/touch /tmp/stopped',
    }

**Note**: it is not recommended to specify passwords in the `conninfo`
option (especially the ones for the `postgres` user). Use a password
file instead (known as `~/.pgpass` file).

#### Parameters

Many of the main configuration parameters can be passed in order to
perform overrides of the global settings. The default values for these
parameters are copied from the ones in `barman` class.

The following parameters are unique to the `server` class:

* **conninfo** - Postgres connection string. **Mandatory**.
* **ssh_command** - Command to open an ssh connection to Postgres.
                    **Mandatory**.
* **ensure** - Ensure the configuration file for the server is present.
               Available values are `present` and `absent`. Default: `present`.
* **conf_template** - Path of the template for the `server.conf` configuration
                      file. You may change this value to use a custom template.
* **description** - A description that will be written in the configuration
                    file. Defaults to the name of the resource.
* **compression** - Compression algorithm. Currently supports `gzip` (default),
                   `bzip2`, and `custom`. Disabled if false.
* **pre_backup_script** - Script to launch before backups. Disabled if false
                          (default).
* **post_backup_script** - Script to launch after backups. Disabled if false
                           (default).
* **pre_archive_script** - Script to launch before a WAL file is archived by
                           maintenance. Disabled if false (default).
* **post_archive_script** - Script to launch after a WAL file is archived by
                           maintenance. Disabled if false (default).
* **immediate_checkpoint** - Force the checkpoint on the Postgres server to
                             happen immediately and start your backup copy
                             process as soon as possible. Disabled if false
                             (default)
* **basebackup_retry_times** - Number of retries fo data copy during base
                               backup after an error. Default = 0
* **basebackup_retry_sleep** - Number of seconds to wait after after a failed
                               copy, before retrying. Default = 30
* **backup_options** - Behavior for backup operations: possible values are
                       exclusive_backup (default) and concurrent_backup
* **minimum_redundancy** - Minimum number of required backups (redundancy).
                           Default = 0
* **last_backup_maximum_age** - Time frame that must contain the latest backup
                                date. If the latest backup is older than the
                                time frame, barman check command will report an
                                error to the user. Empty if false (default).
* **retention_policy** - Base backup retention policy, based on redundancy or
                         recovery window. Default empty (no retention enforced).
                         Value must be greater than or equal to the server
                         minimum redundancy level (if not is is assigned to
                         that value and a warning is generated).
* **wal_retention_policy** - WAL archive logs retention policy. Currently, the
                             only allowed value for wal_retention_policy is the
                             special value main, that maps the retention policy
                             of archive logs to that of base backups.
* **retention_policy_mode** - Can only be set to auto (retention policies are
                              automatically enforced by the barman cron command)
* **reuse_backup** - Incremental backup is a kind of full periodic backup which
                     saves only data changes from the latest full backup
                     available in the catalogue for a specific PostgreSQL
                     server. Disabled if false. Default false.
* **custom_lines** - DEPRECATED. Custom configuration directives (e.g. for
                     custom compression). Defaults to empty.


See the file **server.pp** for more details.

## Autoconfiguration

It is possible to enable the `barman` Puppet module to automatically configure
the Barman server to back up a given PostgreSQL server. It is also possible for
more than one PostgreSQL server to be backed up, and moreover it is possible to
create many "host groups" whose PostgreSQL servers a Barman Server in each group
can back up.

### Enabling autoconfigure

The parameter **barman::settings::autoconfigure** in the **barman** class
enables the inclusion of the Puppet classes involved in the autoconfiguration.
The default value is `false`.

The parameter **barman::settings::host_group** in the **barman** class is used
to create different host groups. If the same value for this parameter is used
for more than a PostgreSQL server, these servers and the Barman server belong
to the same backup cluster ("host group").

Those are the classes involved when autoconfiguration is enabled:

### barman::autoconfigure

This class:

* Creates the `~/.pgpass` file for the `barman` user
* Imports resources exported by the PostgreSQL server (crontab for the backup,
PostgreSQL superuser SSH key, `.pgpass` file, configuration of the single
PostgreSQL server in Barman)
* Exports Barman resources to the PostgreSQL server (`archive_command`, Barman
user SSH key, configurations for the `pg_hba.conf` file)

More details in the **autoconfigure.pp** file.

#### Parameters

* **host_group** - Tag the different host groups for the backup
                   (default value is set from the `settings` class).

* **exported_ipaddress** - The barman server address to allow in the PostgreSQL
                           server ph_hba.conf. Defaults to `${::ipaddress}/32`.

### barman::postgres

This class exports resources to the Barman server (Barman configurations,
cron, SSH key) and imports resources from it (configures `archive_mode`,
defines the `user` used by Barman to connect into the PostgreSQL databases). It
has to be included in the PostgreSQL server.

More details in the **postgres.pp** file.

#### Parameters

* **host_group** - Tag the different host groups for the backup
                   (default value is set from the `settings` class).
* **wal_level** - Configuration of the *wal_level* parameter in the postgresql.conf
                  file. The default value is `archive`.
* **barman_user** - Definition of the `barman` user used in Barman `conninfo`. The
                    default value is set from the `settings` class.
* **barman_dbuser** - Definition of the user used by Barman to connect to the
                      PostgreSQL database(s) in the `conninfo`. The default value is
                      set from the `settings` class.
* **barman_home** - Definition of the barman home directory. The default value
                    is set from the `settings` class.
* **backup_mday** - Day of the month set in the cron for the backup schedule.
                    The default value (undef) ensure daily backups.
* **backup_wday** - Day of the week set in the cron for the backup schedule.
                    The default value (undef) ensure daily backups.
* **backup_hour** - Hour set in the cron for the backup schedule. The default
                    value is 04:XXam.
* **backup_minute** - Minute set in the cron for the backup schedule. The default
                      value is for XX:00am
* **password** - Password used by Barman to connect to PosgreSQL. The default
                 value (empty string) allows the generation of a random password.
* **server_address** - The whole fqdn of the PostgreSQL server used in Barman
                       `ssh_command` automatically configured by Puppet).
* **postgres_server_id** - Id of the PostgreSQL server, given by its host name
                           (automatically configured by Puppet).
* **postgres_user** - The PostgreSQL user used in Barman *ssh_command*.
* **ensure** - Ensure the configuration file for the server is present.
               Available values are `present` and `absent`. Default: `present`.
* **conf_template** - Path of the template for the `server.conf` configuration
                      file. You may change this value to use a custom template.
* **description** - A description that will be written in the configuration
                    file. Defaults to the name of the resource.
* **compression** - Compression algorithm. Currently supports `gzip` (default),
                   `bzip2`, and `custom`. Disabled if false.
* **pre_backup_script** - Script to launch before backups. Disabled if false
                          (default).
* **post_backup_script** - Script to launch after backups. Disabled if false
                           (default).
* **pre_archive_script** - Script to launch before a WAL file is archived by
                           maintenance. Disabled if false (default).
* **post_archive_script** - Script to launch after a WAL file is archived by
                           maintenance. Disabled if false (default).
* **immediate_checkpoint** - Force the checkpoint on the Postgres server to
                             happen immediately and start your backup copy
                             process as soon as possible. Disabled if false
                             (default)
* **basebackup_retry_times** - Number of retries fo data copy during base
                               backup after an error. Default = 0
* **basebackup_retry_sleep** - Number of seconds to wait after after a failed
                               copy, before retrying. Default = 30
* **backup_options** - Behavior for backup operations: possible values are
                       exclusive_backup (default) and concurrent_backup
* **minimum_redundancy** - Minimum number of required backups (redundancy).
                           Default = 0
* **last_backup_maximum_age** - Time frame that must contain the latest backup
                                date. If the latest backup is older than the
                                time frame, barman check command will report an
                                error to the user. Empty if false (default).
* **retention_policy** - Base backup retention policy, based on redundancy or
                         recovery window. Default empty (no retention enforced).
                         Value must be greater than or equal to the server
                         minimum redundancy level (if not is is assigned to
                         that value and a warning is generated).
* **wal_retention_policy** - WAL archive logs retention policy. Currently, the
                             only allowed value for wal_retention_policy is the
                             special value main, that maps the retention policy
                             of archive logs to that of base backups.
* **retention_policy_mode** - Can only be set to auto (retention policies are
                              automatically enforced by the barman cron command)
* **reuse_backup** - Incremental backup is a kind of full periodic backup which
                     saves only data changes from the latest full backup
                     available in the catalogue for a specific PostgreSQL
                     server. Disabled if false. Default false.
* **custom_lines** - DEPRECATED. Custom configuration directives (e.g. for
                     custom compression). Defaults to empty.

## License

This module is distributed under GNU GPLv3.

## Author

* Giuseppe Broccolo <giuseppe.broccolo@2ndQuadrant.it>
* Giulio Calacoci <giulio.calacoci@2ndQuadrant.it>
* Francesco Canovai <francesco.canovai@2ndQuadrant.it>
* Marco Nenciarini <marco.nenciarini@2ndQuadrant.it>
* Gabriele Bartolini <gabriele.bartolini@2ndQuadrant.it>

Many thanks to Alessandro Franceschi <al@lab42.it> for his intensive course
on Puppet and the ideas he brought to this module.

### Past authors

* Alessandro Grassi <alessandro.grassi@devise.it>

### Copyright

Copyright 2012-2015 2ndQuadrant Italia (Devise.IT SRL)
