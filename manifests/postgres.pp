# == Class: postgres
#
# This class export resources to the Barman server (Barman configurations,
# cron, SSH key) and import resources from it (configure 'archive_mode',
# define user used by Barman to connect into PostgreSQL database(s)).
#
# === Parameters
#
# [*host_group*] - Tag the different host groups for the backup
#                  (default value is set from the 'settings' class).
# [*wal_level*] - Configuration of the 'wal_level' parameter in the
#                 postgresql.conf file. The default value is 'archive'.
# [*barman_user*] - Definition of the 'barman' user used in Barman 'conninfo'.
#                   The default value is set from the 'settings' class.
# [*barman_dbuser*] - Definition of the user used by Barman to connect to the
#                     PostgreSQL database(s) in the 'conninfo'. The default
#                     value is set from the 'settings' class.
# [*barman_home*] - Definition of the barman home directory. The default value
#                   is set from the 'settings' class.
# [*backup_mday*] - Day of the month set in the cron for the backup schedule.
#                   The default value (undef) ensure daily backups.
# [*backup_wday*] - Day of the week set in the cron for the backup schedule.
#                   The default value (undef) ensure daily backups.
# [*backup_hour*] - Hour set in the cron for the backup schedule. The default
#                   value is 04:XXam.
# [*backup_minute*] - Minute set in the cron for the backup schedule. The
#                     default value is for XX:00am
# [*password*] - Password used by Barman to connect to PosgreSQL. The default
#                value (empty string) allows the generation of a random
#                password.
# [*server_address*] - The whole fqdn of the PostgreSQL server used in Barman
#                      'ssh_command' (automatically configured by Puppet).
# [*postgres_server_id*] - Id of the PostgreSQL server, given by its host name
#                          (automatically configured by Puppet).
# [*postgres_user*] - The PostgreSQL user used in Barman 'ssh_command'.
# [*ensure*] - Ensure (or not) that single server Barman configuration files are
#              created. The default value is 'present'. Just 'absent' or
#              'present' are the possible settings.
# [*conf_template*] - path of the template file to build the Barman
#                     configuration file.
# [*description*] - Description of the configuration file: it is automatically
#                   set when the resource is used.
# [*compression*] - Compression algorithm. Currently supports 'gzip' (default),
#                   'bzip2', and 'custom'. Disabled if false.
# [*pre_backup_script*] - Script to launch before backups. Disabled if false
#                         (default).
# [*post_backup_script*] - Script to launch after backups. Disabled if false
#                          (default).
# [*pre_archive_script*] - Script to launch before a WAL file is archived by
#                          maintenance. Disabled if false (default).
# [*post_archive_script*] - Script to launch after a WAL file is archived by
#                          maintenance. Disabled if false (default).
# [*immediate_checkpoint*] - Force the checkpoint on the Postgres server to
#                            happen immediately and start your backup copy
#                            process as soon as possible. Disabled if false
#                           (default)
# [*basebackup_retry_times*] - Number of retries fo data copy during base
#                              backup after an error. Default = 0
# [*basebackup_retry_sleep*] - Number of seconds to wait after after a failed
#                              copy, before retrying. Default = 30
# [*backup_options*] - Behavior for backup operations: possible values are
#                      exclusive_backup (default) and concurrent_backup
# [*minimum_redundancy*] - Minimum number of required backups (redundancy).
#                          Default = 0
# [*last_backup_maximum_age*] - Time frame that must contain the latest backup
#                               date. If the latest backup is older than the
#                               time frame, barman check command will report an
#                               error to the user. Empty if false (default).
# [*retention_policy*] - Base backup retention policy, based on redundancy or
#                        recovery window. Default empty (no retention enforced).
#                        Value must be greater than or equal to the server
#                        minimum redundancy level (if not is is assigned to
#                        that value and a warning is generated).
# [*wal_retention_policy*] - WAL archive logs retention policy. Currently, the
#                            only allowed value for wal_retention_policy is the
#                            special value main, that maps the retention policy
#                            of archive logs to that of base backups.
# [*retention_policy_mode*] - Can only be set to auto (retention policies are
#                             automatically enforced by the barman cron command)
# [*reuse_backup*] - Incremental backup is a kind of full periodic backup which
#                    saves only data changes from the latest full backup
#                    available in the catalogue for a specific PostgreSQL
#                    server. Disabled if false. Default false.
# [*custom_lines*] - DEPRECATED. Custom configuration directives (e.g. for
#                    custom compression). Defaults to empty.
# === Examples
#
# The class can be used right away with defaults:
# ---
#  include postgres
# ---
#
# All parameters that are supported by barman can be changed:
# ---
#  class { postgres :
#    backup_hour   => 4,
#    backup_minute => 0,
#    password      => 'not_needed',
#    postgres_user => 'postgres',
#  }
# ---
#
# === Authors
#
# * Giuseppe Broccolo <giuseppe.broccolo@2ndQuadrant.it>
# * Giulio Calacoci <giulio.calacoci@2ndQuadrant.it>
# * Francesco Canovai <francesco.canovai@2ndQuadrant.it>
# * Marco Nenciarini <marco.nenciarini@2ndQuadrant.it>
# * Gabriele Bartolini <gabriele.bartolini@2ndQuadrant.it>
#
# Many thanks to Alessandro Franceschi <al@lab42.it>
#
# === Past authors
#
# Alessandro Grassi <alessandro.grassi@devise.it>
#
# === Copyright
#
# Copyright 2012-2015 2ndQuadrant Italia (Devise.IT SRL)
#
class barman::postgres (
  $host_group              = $::barman::settings::host_group,
  $wal_level               = 'archive',
  $barman_user             = $::barman::settings::user,
  $barman_dbuser           = $::barman::settings::dbuser,
  $barman_dbname           = $::barman::settings::dbname,
  $barman_home             = $::barman::settings::home,
  $backup_mday             = undef,
  $backup_wday             = undef,
  $backup_hour             = 4,
  $backup_minute           = 0,
  $password                = '',
  $server_address          = $::fqdn,
  $postgres_server_id      = $::hostname,
  $postgres_user           = 'postgres',
  $ensure                  = 'present',
  $conf_template           = 'barman/server.conf.erb',
  $description             = $name,
  $compression             = $::barman::compression,
  $immediate_checkpoint    = $::barman::immediate_checkpoint,
  $pre_backup_script       = $::barman::pre_backup_script,
  $post_backup_script      = $::barman::post_backup_script,
  $pre_archive_script      = $::barman::pre_archive_script,
  $post_archive_script     = $::barman::post_archive_script,
  $basebackup_retry_times  = $::barman::basebackup_retry_times,
  $basebackup_retry_sleep  = $::barman::basebackup_retry_sleep,
  $backup_options          = $::barman::backup_options,
  $minimum_redundancy      = $::barman::minimum_redundancy,
  $last_backup_maximum_age = $::barman::last_backup_maximum_age,
  $retention_policy        = $::barman::retention_policy,
  $retention_policy_mode   = $::barman::retention_policy_mode,
  $wal_retention_policy    = $::barman::wal_retention_policy,
  $reuse_backup            = $::barman::reuse_backup,
  $custom_lines            = $::barman::custom_lines,
) inherits ::barman::settings {

  if !defined(Class['postgresql::server']) {
    fail('barman::server requires the postgresql::server module installed and configured')
  }

  # Generate a new password if not defined
  $real_password = $password ? {
    ''      => fqdn_rand_string('30','','fwsfbsfw'),
    default => $password,
  }

  # Configure PostgreSQL server for archive mode
  postgresql::server::config_entry {
    'archive_mode': value => 'on';
    'wal_level': value => $wal_level;
  }

  # define user used by Barman to connect into PostgreSQL database(s)
  postgresql::server::role { $barman_dbuser:
    login         => true,
    password_hash => postgresql_password($barman_dbuser, $real_password),
    superuser     => true,
  }

  # Collect resources exported by Barman server
  Barman::Archive_command <<| tag == "barman-${host_group}" |>> {
    postgres_server_id => $postgres_server_id,
  }

  Postgresql::Server::Pg_hba_rule <<| tag == "barman-${host_group}" |>>

  Ssh_authorized_key <<| tag == "barman-${host_group}" |>> {
    require => Class['postgresql::server'],
  }

  # Export resources to Barman server
  @@barman::server { $postgres_server_id:
    conninfo                => "user=${barman_dbuser} dbname=${barman_dbname} host=${server_address}",
    ssh_command             => "ssh ${postgres_user}@${server_address}",
    tag                     => "barman-${host_group}",
    compression             => $compression,
    immediate_checkpoint    => $immediate_checkpoint,
    pre_backup_script       => $pre_backup_script,
    post_backup_script      => $post_backup_script,
    pre_archive_script      => $pre_archive_script,
    post_archive_script     => $post_archive_script,
    basebackup_retry_times  => $basebackup_retry_times,
    basebackup_retry_sleep  => $basebackup_retry_sleep,
    backup_options          => $backup_options,
    minimum_redundancy      => $minimum_redundancy,
    last_backup_maximum_age => $last_backup_maximum_age,
    retention_policy        => $retention_policy,
    retention_policy_mode   => $retention_policy_mode,
    wal_retention_policy    => $wal_retention_policy,
    reuse_backup            => $reuse_backup,
    custom_lines            => $custom_lines,
  }

  @@cron { "barman_backup_${::hostname}":
    command  => "[ -x /usr/bin/barman ] && /usr/bin/barman -q backup ${::hostname}",
    user     => 'root',
    monthday => $backup_mday,
    weekday  => $backup_wday,
    hour     => $backup_hour,
    minute   => $backup_minute,
    tag      => "barman-${host_group}",
  }

  # Fill the .pgpass file
  @@file_line { "barman_pgpass_content-${::hostname}":
    path => "${barman_home}/.pgpass",
    line => "${server_address}:*:${barman_dbname}:${barman_dbuser}:${real_password}",
    tag  => "barman-${host_group}",
  }

  # Ssh key of 'postgres' user in PostgreSQL server
  if ($::postgres_key != undef and $::postgres_key != '') {
    $postgres_key_splitted = split($::postgres_key, ' ')
    @@ssh_authorized_key { "postgres-${::hostname}":
      ensure => present,
      user   => $barman_user,
      type   => $postgres_key_splitted[0],
      key    => $postgres_key_splitted[1],
      tag    => "barman-${host_group}-postgresql",
    }
  }
}
