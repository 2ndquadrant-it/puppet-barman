# == Class: barman
#
# This class installs Barman (Backup and recovery manager for Postgres).
#
# === Parameters
#
# [*user*] - The Barman user. Its value is set by 'settings' class.
# [*group*] - The group of the Barman user. Its value is set by 'settings'
#             class.
# [*ensure*] - Ensure that Barman is installed. The default value is 'present'.
#              Otherwise it will be set as 'absent'.
# [*conf_template*] - Path of the template of the barman.conf configuration
#                     file. The default value does not need to be changed.
# [*logrotate_template*] - Path of the template of the logrotate.conf file.
#                          The default value does not need to be changed.
# [*home*] - A different place for backups than the default. Will be symlinked
#            to the default (/var/lib/barman). You should not change this
#            value after the first setup. Its value is set by the 'settings'
#            class.
# [*logfile*] - A different log file. The default is
#               '/var/log/barman/barman.log'
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
# [*barman_fqdn*] - The fqdn of the Barman server. It will be exported in
#                   several resources in the PostgreSQL server. Puppet
#                   automatically set this.
# [*autoconfigure*] - This is the main parameter to enable the
#                     autoconfiguration of the backup of a given PostgreSQL
#                     server. Defaults to false.
# [*exported_ipaddress*] - The ipaddress exported to the PostgreSQL server
#                          during atutoconfiguration. Defaults to
#                          "${::ipaddress}/32".
# [*host_group*] -  Tag used to collect and export resources during
#                   autoconfiguration. Defaults to 'global'.
# [*manage_package_repo*] - Configure PGDG repository. It is implemented
#                           internally by declaring the `postgresql::globals`
#                           class. If you need to customize the
#                           `postgresql::globals` class declaration, keep the
#                           `manage_package_repo` parameter disabled in `barman`
#                           module and enable it directly in
#                           `postgresql::globals` class.
# [*purge_unknown_conf*] - Whether or not barman conf files not included in
#                          puppetdb will be removed by puppet.
#
# === Facts
#
# The module generates a fact called '*barman_key*' which has the content of
#  _/var/lib/barman/.ssh/id_rsa.pub_, in order to automatically handle the
#  key exchange on the postgres server via puppetdb.
# If the file doesn't exist, a key will be generated.
#
# === Examples
#
# The class can be used right away with defaults:
# ---
#  include barman
# ---
#
# All parameters that are supported by barman can be changed:
# ---
#  class { barman:
#    logfile  => '/var/log/barman/something_else.log',
#    compression => 'bzip2',
#    pre_backup_script => '/usr/bin/touch /tmp/started',
#    post_backup_script => '/usr/bin/touch /tmp/stopped',
#    custom_lines => '; something'
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
class barman (
  $user                    = $::barman::settings::user,
  $group                   = $::barman::settings::group,
  $ensure                  = 'present',
  $conf_template           = 'barman/barman.conf.erb',
  $logrotate_template      = 'barman/logrotate.conf.erb',
  $barman_fqdn             = $::fqdn,
  $home                    = $::barman::settings::home,
  $logfile                 = $::barman::settings::logfile,
  $compression             = $::barman::settings::compression,
  $immediate_checkpoint    = $::barman::settings::immediate_checkpoint,
  $pre_backup_script       = $::barman::settings::pre_backup_script,
  $post_backup_script      = $::barman::settings::post_backup_script,
  $pre_archive_script      = $::barman::settings::pre_archive_script,
  $post_archive_script     = $::barman::settings::post_archive_script,
  $basebackup_retry_times  = $::barman::settings::basebackup_retry_times,
  $basebackup_retry_sleep  = $::barman::settings::basebackup_retry_sleep,
  $backup_options          = $::barman::settings::backup_options,
  $minimum_redundancy      = $::barman::settings::minimum_redundancy,
  $last_backup_maximum_age = $::barman::settings::last_backup_maximum_age,
  $retention_policy        = $::barman::settings::retention_policy,
  $retention_policy_mode   = $::barman::settings::retention_policy_mode,
  $wal_retention_policy    = $::barman::settings::wal_retention_policy,
  $reuse_backup            = $::barman::settings::reuse_backup,
  $custom_lines            = $::barman::settings::custom_lines,
  $autoconfigure           = $::barman::settings::autoconfigure,
  $manage_package_repo     = $::barman::settings::manage_package_repo,
  $exported_ipaddress      = "${::ipaddress}/32",
  $host_group              = $::barman::settings::host_group,
  $purge_unknown_conf      = $::barman::settings::purge_unknown_conf,
) inherits barman::settings {

  # Check if autoconfigure is a boolean
  validate_bool($autoconfigure)

  # Check if minimum_redundancy is a number
  validate_re($minimum_redundancy, [ '^[0-9]+$' ])

  # Check if backup_options has correct values
  validate_re($backup_options, [ '^exclusive_backup$', '^concurrent_backup$', 'Invalid backup option please use exclusive_backup or concurrent_backup' ])

  # Check if immediate checkpoint is a boolean
  validate_bool($immediate_checkpoint)

  # Check to make sure basebackup_retry_times is a numerical value
  if $basebackup_retry_times != false {
    validate_re($basebackup_retry_times, [ '^[0-9]+$' ])
  }
  # Check to make sure basebackup_retry_sleep is a numerical value
  if $basebackup_retry_sleep != false {
    validate_re($basebackup_retry_sleep, [ '^[0-9]+$' ])
  }

  # Check to make sure last_backup_maximum_age identifies (DAYS | WEEKS | MONTHS) greater then 0
  if $last_backup_maximum_age != false {
    validate_re($last_backup_maximum_age, [ '^[1-9][0-9]* (DAY|WEEK|MONTH)S?$' ])
  }

  # Check to make sure retention_policy has correct value
  validate_re($retention_policy, [ '^(^$|REDUNDANCY [1-9][0-9]*|RECOVERY WINDOW OF [1-9][0-9]* (DAY|WEEK|MONTH)S?)$' ])

  # Check to make sure retention_policy_mode is set to auto
  validate_re($retention_policy_mode, [ '^auto$' ])

  # Check to make sure wal_retention_policy is set to main
  validate_re($wal_retention_policy, [ '^main$' ])

  # Check to make sure reuse_backup has correct value
  if $reuse_backup != false {
    validate_re($reuse_backup, [ '^(off|link|copy)$' ])
  }

  # Ensure creation (or removal) of Barman files and directories
  $ensure_file = $ensure ? {
    'absent' => 'absent',
    default  => 'present',
  }
  $ensure_directory = $ensure ? {
    'absent' => 'absent',
    default  => 'directory',
  }

  if $manage_package_repo {
    if defined(Class['postgresql::globals']) {
      fail('Class postgresql::globals is already defined. Set barman class manage_package_repo parameter to false (preferred) or remove the other definition.')
    } else {
      class { 'postgresql::globals':
        manage_package_repo => true,
      }
    }
  }
  package { 'barman':
    ensure => $ensure,
    tag    => 'postgresql',
  }

  file { '/etc/barman.conf.d':
    ensure  => $ensure_directory,
    purge   => $purge_unknown_conf,
    recurse => true,
    owner   => 'root',
    group   => $group,
    mode    => '0750',
    require => Package['barman'],
  }

  file { '/etc/barman.conf':
    ensure  => $ensure_file,
    owner   => 'root',
    group   => $group,
    mode    => '0640',
    content => template($conf_template),
    require => File['/etc/barman.conf.d'],
  }

  file { $home:
    ensure  => $ensure_directory,
    owner   => $user,
    group   => $group,
    mode    => '0750',
    require => Package['barman']
  }

  # Run 'barman check all' to create Barman backup directories
  exec { 'barman-check-all':
    command     => '/usr/bin/barman check all',
    subscribe   => File[$home],
    refreshonly => true
  }

  file { '/etc/logrotate.d/barman':
    ensure  => $ensure_file,
    owner   => 'root',
    group   => $group,
    mode    => '0644',
    content => template($logrotate_template),
    require => Package['barman']
  }

  # Set the autoconfiguration
  if $autoconfigure {
    class { '::barman::autoconfigure':
      exported_ipaddress => $exported_ipaddress,
      host_group         => $host_group,
      }
  }
}
