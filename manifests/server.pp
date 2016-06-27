# == Resource: barman::server
#
# This resource creates a barman configuration for a postgresql instance.
#
# NOTE: The resource is called in the 'postgres' class.
#
# === Parameters
#
# Many of the main configuration parameters can ( and *must*) be passed in
# order to perform overrides.
#
# [*conninfo*] - Postgres connection string. *Mandatory*.
# [*ssh_command*] - Command to open an ssh connection to Postgres. *Mandatory*.
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
#  barman::server { 'main':
#    conninfo           => 'user=postgres host=server1 password=pg123',
#    ssh_command        => 'ssh postgres@server1',
#    compression        => 'bzip2',
#    pre_backup_script  => '/usr/bin/touch /tmp/started',
#    post_backup_script => '/usr/bin/touch /tmp/stopped',
#    custom_lines       => '; something'
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
define barman::server (
  $conninfo,
  $ssh_command,
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
) {

  # check if 'description' has been correctly configured
  validate_re($ensure, '^(present|absent)$', "${ensure} is not a valid value (ensure = present|absent).")

  # check if backup_options has correct values
  validate_re($backup_options, [ '^exclusive_backup$', '^concurrent_backup$', 'Invalid backup option please use exclusive_backup or concurrent_backup' ])

  # check if 'description' has been correctly configured
  validate_re($name, '^[0-9a-z\-/]*$', "${name} is not a valid name. Please only use lowercase letters, numbers, slashes and hyphens.")

  # check if immediate checkpoint is a boolean
  validate_bool($immediate_checkpoint)

  # check to make sure basebackup_retry_times is a numerical value
  if $basebackup_retry_times != false {
    validate_integer($basebackup_retry_times, undef, 0)
  }

  # check to make sure basebackup_retry_sleep is a numerical value
  if $basebackup_retry_sleep != false {
    validate_integer($basebackup_retry_sleep, undef, 0)
  }

  # check if minimum_redundancy is a number
  validate_integer($minimum_redundancy, undef, 0)

  # check to make sure last_backup_maximum_age identifies (DAYS | WEEKS | MONTHS) greater then 0
  if $last_backup_maximum_age != false {
    validate_re($last_backup_maximum_age, [ '^[1-9][0-9]* (DAY|WEEK|MONTH)S?$' ])
  }

  # check to make sure retention_policy has correct value
  validate_re($retention_policy, [ '^(^$|REDUNDANCY [1-9][0-9]*|RECOVERY WINDOW OF [1-9][0-9]* (DAY|WEEK|MONTH)S?)$' ])

  # check to make sure retention_policy_mode is set to auto
  validate_re($retention_policy_mode, [ '^auto$' ])

  # check to make sure wal_retention_policy is set to main
  validate_re($wal_retention_policy, [ '^main$' ])

  # check to make sure reuse_backup has correct value
  if $reuse_backup != false {
    validate_re($reuse_backup, [ '^(off|link|copy)$' ])
  }

  if $custom_lines != '' {
    notice 'The \'custom_lines\' option is deprecated. Please use $conf_template for custom configuration'
  }

  file { "/etc/barman.conf.d/${name}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $::barman::settings::group,
    content => template($conf_template),
  }

  # Run 'barman check' to create Barman configuration directories
  exec { "barman-check-${name}":
    command     => "barman check ${name} || true",
    provider    => shell,
    subscribe   => File["/etc/barman.conf.d/${name}.conf"],
    refreshonly => true
  }
}
