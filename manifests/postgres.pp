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
# [*manage_ssh_host_keys*] - When using autoconfigure, ensure the hosts contain
#                            each other ssh host key. Must also be set on 'barman'
#                            class. Defaults to false.
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
# [*server_port*] - The port used by PostgreSQL for receiving connections
#                   (default: 5432)
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
# [*archiver*] - Whether the log shipping backup mechanism is active or not.
# [*archiver_batch_size*] - Setting this option enables batch processing of WAL
#                           files. The default processes all currently available
#                           files.
# [*backup_directory*] - Directory where backup data for a server will be placed.
# [*backup_method*] - Configure the method barman used for backup execution. If
#                     set to rsync (default), barman will execute backup using the
#                     rsync command. If set to postgres barman will use the
#                     pg_basebackup command to execute the backup.
# [*backup_options*] - Behavior for backup operations: possible values are
#                      exclusive_backup (default) and concurrent_backup.
# [*recovery_options*] - The restore command to write in the recovery.conf.
#                        Possible values are 'get-wal' and undef. Default: undef.
# [*bandwidth_limit*] - This option allows you to specify a maximum transfer rate
#                       in kilobytes per second. A value of zero specifies no
#                       limit (default).
# [*basebackups_directory*] - Directory where base backups will be placed.
# [*basebackup_retry_sleep*] - Number of seconds of wait after a failed copy,
#                              before retrying Used during both backup and
#                              recovery operations. Positive integer, default 30.
# [*basebackup_retry_times*] - Number of retries of base backup copy, after an
#                              error. Used during both backup and recovery
#                              operations. Positive integer, default 0.
# [*check_timeout*] - Maximum execution time, in seconds per server, for a barman
#                     check command. Set to 0 to disable the timeout. Positive
#                     integer, default 30.
# [*compression*] - Compression algorithm. Currently supports 'gzip' (default),
#                   'bzip2', and 'custom'. Disabled if false.
# [*custom_compression_filter*] - Customised compression algorithm applied to WAL
#                                 files.
# [*custom_decompression_filter*] - Customised decompression algorithm applied to
#                                   compressed WAL files; this must match the
#                                   compression algorithm.
# [*errors_directory*] - Directory that contains WAL files that contain an error.
# [*immediate_checkpoint*] - Force the checkpoint on the Postgres server to
#                            happen immediately and start your backup copy
#                            process as soon as possible. Disabled if false
#                            (default)
# [*incoming_wals_directory*] - Directory where incoming WAL files are archived
#                               into. Requires archiver to be enabled.
# [*last_backup_maximum_age*] - This option identifies a time frame that must
#                               contain the latest backup. If the latest backup is
#                               older than the time frame, barman check command
#                               will report an error to the user. If empty
#                               (default), latest backup is always considered
#                               valid. Syntax for this option is: "i (DAYS |
#                               WEEKS | MONTHS)" where i is a integer greater than
#                               zero, representing the number of days | weeks |
#                               months of the time frame.
# [*minimum_redundancy*] - Minimum number of backups to be retained. Default 0.
# [*network_compression*] - This option allows you to enable data compression for
#                           network transfers. Defaults to false.
# [*parallel_jobs] - Number of parallel workers used to copy files during
#                    backup or recovery. Requires backup mode = rsync.
# [*path_prefix*] - One or more absolute paths, separated by colon, where Barman
#                   looks for executable files.
# [*post_archive_retry_script*] - Hook script launched after a WAL file is
#                                 archived by maintenance. Being this a retry hook
#                                 script, Barman will retry the execution of the
#                                 script until this either returns a SUCCESS (0),
#                                 an ABORT_CONTINUE (62) or an ABORT_STOP (63)
#                                 code. In a post archive scenario, ABORT_STOP has
#                                 currently the same effects as ABORT_CONTINUE.
# [*post_archive_script*] - Hook script launched after a WAL file is archived by
#                           maintenance, after 'post_archive_retry_script'.
# [*post_backup_retry_script*] - Hook script launched after a base backup. Being
#                                this a retry hook script, Barman will retry the
#                                execution of the script until this either returns
#                                a SUCCESS (0), an ABORT_CONTINUE (62) or an
#                                ABORT_STOP (63) code. In a post backup scenario,
#                                ABORT_STOP has currently the same effects as
#                                ABORT_CONTINUE.
# [*post_backup_script*] - Hook script launched after a base backup, after
#                          'post_backup_retry_script'.
# [*pre_archive_retry_script*] - Hook script launched before a WAL file is
#                                archived by maintenance, after
#                                'pre_archive_script'. Being this a retry hook
#                                script, Barman will retry the execution of the
#                                script until this either returns a SUCCESS (0),
#                                an ABORT_CONTINUE (62) or an ABORT_STOP (63)
#                                code. Returning ABORT_STOP will propagate the
#                                failure at a higher level and interrupt the WAL
#                                archiving operation.
# [*pre_archive_script*] - Hook script launched before a WAL file is archived by
#                          maintenance.
# [*pre_backup_retry_script*] - Hook script launched before a base backup, after
#                               'pre_backup_script'. Being this a retry hook
#                               script, Barman will retry the execution of the
#                               script until this either returns a SUCCESS (0), an
#                               ABORT_CONTINUE (62) or an ABORT_STOP (63) code.
#                               Returning ABORT_STOP will propagate the failure at
#                               a higher level and interrupt the backup operation.
# [*pre_backup_script*] - Hook script launched before a base backup.
# [*retention_policy*] - Base backup retention policy, based on redundancy or
#                        recovery window. Default empty (no retention enforced).
#                        Value must be greater than or equal to the server
#                        minimum redundancy level (if not is is assigned to
#                        that value and a warning is generated).
# [*retention_policy_mode*] - Can only be set to auto (retention policies are
#                             automatically enforced by the barman cron command)
# [*reuse_backup*] - Incremental backup is a kind of full periodic backup which
#                    saves only data changes from the latest full backup
#                    available in the catalogue for a specific PostgreSQL
#                    server. Disabled if false. Default false.
# [*slot_name*] - Physical replication slot to be used by the receive-wal
#                 command when streaming_archiver is set to on. Requires
#                 postgreSQL >= 9.4. Default: undef (disabled).
# [*streaming_archiver*] - This option allows you to use the PostgreSQL's
#                          streaming protocol to receive transaction logs from a
#                          server. This activates connection checks as well as
#                          management (including compression) of WAL files. If
#                          set to off (default) barman will rely only on
#                          continuous archiving for a server WAL archive
#                          operations, eventually terminating any running
#                          pg_receivexlog for the server.
# [*streaming_archiver_batch_size*] - This option allows you to activate batch
#                                     processing of WAL files for the
#                                     streaming_archiver process, by setting it to
#                                     a value > 0. Otherwise, the traditional
#                                     unlimited processing of the WAL queue is
#                                     enabled.
# [*streaming_archiver_name*] - Identifier to be used as application_name by the
#                               receive-wal command. Only available with
#                               pg_receivexlog >= 9.3. By default it is set to
#                               barman_receive_wal.
# [*streaming_backup_name*] - Identifier to be used as application_name by the
#                             pg_basebackup command. Only available with
#                             pg_basebackup >= 9.3. By default it is set to
#                             barman_streaming_backup.
# [*streaming_conninfo*] - Connection string used by Barman to connect to the
#                          Postgres server via streaming replication protocol. By
#                          default it is set to the same value as *conninfo*.
# [*streaming_wals_directory*] - Directory where WAL files are streamed from the
#                                PostgreSQL server to Barman.
# [*tablespace_bandwidth_limit*] - This option allows you to specify a maximum
#                                  transfer rate in kilobytes per second, by
#                                  specifying a comma separated list of
#                                  tablespaces (pairs TBNAME:BWLIMIT). A value of
#                                  zero specifies no limit (default).
# [*wal_retention_policy*] - WAL archive logs retention policy. Currently, the
#                            only allowed value for wal_retention_policy is the
#                            special value main, that maps the retention policy
#                            of archive logs to that of base backups.
# [*wals_directory*] - Directory which contains WAL files.
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
# * Alessandro Grassi <alessandro.grassi@2ndQuadrant.it>
#
# Many thanks to Alessandro Franceschi <al@lab42.it>
#
# === Copyright
#
# Copyright 2012-2017 2ndQuadrant Italia
#
class barman::postgres (
  $host_group                    = $::barman::settings::host_group,
  $wal_level                     = 'archive',
  $barman_user                   = $::barman::settings::user,
  $barman_dbuser                 = $::barman::settings::dbuser,
  $barman_dbname                 = $::barman::settings::dbname,
  $barman_home                   = $::barman::settings::home,
  $backup_mday                   = undef,
  $backup_wday                   = undef,
  $backup_hour                   = 4,
  $backup_minute                 = 0,
  $password                      = '',
  $server_address                = $::fqdn,
  $server_port                   = 5432,
  $postgres_server_id            = $::hostname,
  $postgres_user                 = 'postgres',
  $ensure                        = 'present',
  $conf_template                 = 'barman/server.conf.erb',
  $description                   = $name,
  $archiver                      = $::barman::archiver,
  $archiver_batch_size           = $::barman::archiver_batch_size,
  $backup_directory              = undef,
  $backup_method                 = $::barman::backup_method,
  $backup_options                = $::barman::backup_options,
  $bandwidth_limit               = $::barman::bandwidth_limit,
  $basebackups_directory         = undef,
  $basebackup_retry_sleep        = $::barman::basebackup_retry_sleep,
  $basebackup_retry_times        = $::barman::basebackup_retry_times,
  $check_timeout                 = $::barman::check_timeout,
  $compression                   = $::barman::compression,
  $custom_compression_filter     = $::barman::custom_compression_filter,
  $custom_decompression_filter   = $::barman::custom_decompression_filter,
  $errors_directory              = undef,
  $immediate_checkpoint          = $::barman::immediate_checkpoint,
  $incoming_wals_directory       = undef,
  $last_backup_maximum_age       = $::barman::last_backup_maximum_age,
  $minimum_redundancy            = $::barman::minimum_redundancy,
  $manage_ssh_host_keys          = $::barman::manage_ssh_host_keys,
  $network_compression           = $::barman::network_compression,
  $parallel_jobs                 = $::barman::parallel_jobs,
  $path_prefix                   = $::barman::path_prefix,
  $post_archive_retry_script     = $::barman::post_archive_retry_script,
  $post_archive_script           = $::barman::post_archive_script,
  $post_backup_retry_script      = $::barman::post_backup_retry_script,
  $post_backup_script            = $::barman::post_backup_script,
  $pre_archive_retry_script      = $::barman::pre_archive_retry_script,
  $pre_archive_script            = $::barman::pre_archive_script,
  $pre_backup_retry_script       = $::barman::pre_backup_retry_script,
  $pre_backup_script             = $::barman::pre_backup_script,
  $recovery_options              = $::barman::settings::recovery_options,
  $retention_policy              = $::barman::retention_policy,
  $retention_policy_mode         = $::barman::retention_policy_mode,
  $reuse_backup                  = $::barman::reuse_backup,
  $slot_name                     = $::barman::slot_name,
  $streaming_archiver            = $::barman::streaming_archiver,
  $streaming_archiver_batch_size = $::barman::streaming_archiver_batch_size,
  $streaming_archiver_name       = $::barman::streaming_archiver_name,
  $streaming_backup_name         = $::barman::streaming_backup_name,
  $streaming_conninfo            = undef,
  $streaming_wals_directory      = undef,
  $tablespace_bandwidth_limit    = $::barman::tablespace_bandwidth_limit,
  $wal_retention_policy          = $::barman::wal_retention_policy,
  $wals_directory                = undef,
  $custom_lines                  = $::barman::custom_lines,
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
  Postgresql::Server::Pg_hba_rule <<| tag == "barman-${host_group}" |>>

  Ssh_authorized_key <<| tag == "barman-${host_group}" |>> {
    require => Class['postgresql::server'],
  }

  # Export resources to Barman server
  @@barman::server { $postgres_server_id:
    conninfo                      => "user=${barman_dbuser} dbname=${barman_dbname} host=${server_address} port=${server_port}",
    ssh_command                   => "ssh -q ${postgres_user}@${server_address}",
    tag                           => "barman-${host_group}",
    archiver                      => $archiver,
    archiver_batch_size           => $archiver_batch_size,
    backup_directory              => $backup_directory,
    backup_method                 => $backup_method,
    backup_options                => $backup_options,
    bandwidth_limit               => $bandwidth_limit,
    basebackups_directory         => $basebackups_directory,
    basebackup_retry_sleep        => $basebackup_retry_sleep,
    basebackup_retry_times        => $basebackup_retry_times,
    check_timeout                 => $check_timeout,
    compression                   => $compression,
    custom_compression_filter     => $custom_compression_filter,
    custom_decompression_filter   => $custom_decompression_filter,
    errors_directory              => $errors_directory,
    immediate_checkpoint          => $immediate_checkpoint,
    incoming_wals_directory       => $incoming_wals_directory,
    last_backup_maximum_age       => $last_backup_maximum_age,
    minimum_redundancy            => $minimum_redundancy,
    network_compression           => $network_compression,
    path_prefix                   => $path_prefix,
    parallel_jobs                 => $parallel_jobs,
    post_archive_retry_script     => $post_archive_retry_script,
    post_archive_script           => $post_archive_script,
    post_backup_retry_script      => $post_backup_retry_script,
    post_backup_script            => $post_backup_script,
    pre_archive_retry_script      => $pre_archive_retry_script,
    pre_archive_script            => $pre_archive_script,
    pre_backup_retry_script       => $pre_backup_retry_script,
    pre_backup_script             => $pre_backup_script,
    retention_policy              => $retention_policy,
    retention_policy_mode         => $retention_policy_mode,
    reuse_backup                  => $reuse_backup,
    slot_name                     => $slot_name,
    streaming_archiver            => $streaming_archiver,
    streaming_archiver_batch_size => $streaming_archiver_batch_size,
    streaming_archiver_name       => $streaming_archiver_name,
    streaming_backup_name         => $streaming_backup_name,
    streaming_conninfo            => $streaming_conninfo,
    streaming_wals_directory      => $streaming_wals_directory,
    tablespace_bandwidth_limit    => $tablespace_bandwidth_limit,
    wal_retention_policy          => $wal_retention_policy,
    wals_directory                => $wals_directory,
    custom_lines                  => $custom_lines,
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
    line => "${server_address}:${server_port}:${barman_dbname}:${barman_dbuser}:${real_password}",
    tag  => "barman-${host_group}",
  }
  if $streaming_archiver {
    @@file_line { "barman_pgpass_content-${::hostname}-replication":
      path => "${barman_home}/.pgpass",
      line => "${server_address}:${server_port}:replication:${barman_dbuser}:${real_password}",
      tag  => "barman-${host_group}",
    }
  }

  if $manage_ssh_host_keys {
    @@sshkey { "postgres-${::hostname}":
      ensure       => present,
      host_aliases => [$::hostname, $::fqdn, $::ipaddress],
      key          => $::sshecdsakey,
      type         => 'ecdsa-sha2-nistp256',
      target       => "${barman_home}/.ssh/known_hosts",
      tag          => "barman-${host_group}-postgresql",
    }
    Sshkey <<| tag == "barman-${host_group}" |>>
  }

  if $archiver {
    # If barman archiver is enabled, export the ssh key of postgres user
    # into barman and set the archive command
    if ($::postgres_key != undef and $::postgres_key != '') {
      $postgres_key_split = split($::postgres_key, ' ')
      @@ssh_authorized_key { "postgres-${::hostname}":
        ensure => present,
        user   => $barman_user,
        type   => $postgres_key_split[0],
        key    => $postgres_key_split[1],
        tag    => "barman-${host_group}-postgresql",
      }
    }
    Barman::Archive_command <<| tag == "barman-${host_group}" |>> {
      postgres_server_id => $postgres_server_id,
    }

  }
}
