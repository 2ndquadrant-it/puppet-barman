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
# [*logfile*] - A different log file. The default is '/var/log/barman/barman.log'
# [*compression*] - Compression algorithm. Currently supports 'gzip' (default),
#                   'bzip2', and 'custom'. Disabled if false.
# [*pre_backup_script*] - Script to launch before backups. Disabled if false
#                         (default).
# [*post_backup_script*] - Script to launch after backups. Disabled if false
#                          (default).
# [*pre_archive_script*] - Script to launch before a WAL file is archived by maintenance. Disabled if false
#                          (default).
# [*post_archive_script*] - Script to launch after a WAL file is archived by maintenance. Disabled if false
#                          (default).
# [*immediate_checkpoint*] -  Force the checkpoint on the Postgres server to happen immediately and start your backup copy process as soon as possible. Disabled if false
#                          (default.)
# [*basebackup_retry_times*] - Number of retries fo data copy during base backup after an error. Default = 0
# [*basebackup_retry_sleep*] - Number of seconds to wait after after a failed copy, before retrying. Default = 30
# [*backup_options*] - Behavior for backup operations: possible values are exclusive_backup (default)
#                      and concurrent_backup
# [*custom_lines*] - Custom configuration directives (e.g. for custom
#                    compression). Defaults to empty.
# [*barman_fqdn*] - The fqdn of the Barman server. It will be exported in several
#                   resources in the PostgreSQL server. Puppet automatically set
#                    this.
# [*autoconfigure*] - This is the main parameter to enable the autoconfiguration
#                     of the backup of a given PostgreSQL server. Its value is set
#                     by 'settings' class.
#
# NOTE: 'log_file', 'compression', 'pre_backup_scripts', 'post_backup_scripts'
#       and 'custom_lines' are not set by 'settings' class because they included
#       into resources present both in Barman and PostgreSQL server, so they
#       have to be configurable when the 'barman' resource is created.
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
# All parameters that are supported by barman (not configured by the 'barman' class)
# can be changed:
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
# Copyright 2012-2014 2ndQuadrant Italia (Devise.IT SRL)
#
class barman (
  $user                   = $::barman::settings::user,
  $group                  = $::barman::settings::group,
  $ensure                 = 'present',
  $conf_template          = 'barman/barman.conf.erb',
  $logrotate_template     = 'barman/logrotate.conf.erb',
  $home                   = $::barman::settings::home,
  $logfile                = '/var/log/barman/barman.log',
  $compression            = 'gzip',
  $immediate_checkpoint   = false,
  $pre_backup_script      = false,
  $post_backup_script     = false,
  $pre_archive_script     = false,
  $post_archive_scirpt    = false,
  $basebackup_retry_times = false,
  $basebackup_retry_sleep = false,
  $backup_options         = 'exclusive_backup',
  $custom_lines           = undef,
  $barman_fqdn            = $::fqdn,
  $autoconfigure          = $::barman::settings::autoconfigure,
  $manage_package_repo    = $::barman::settings::manage_package_repo,
) inherits barman::settings {

  # Check if autoconfigure is a boolean
  validate_bool($autoconfigure)

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
    class { 'postgresql::globals':
      manage_package_repo => true,
    }
  }
  package { 'barman':
    ensure  => $ensure,
    tag     => 'postgresql',
  }

  file { '/etc/barman.conf.d':
    ensure  => $ensure_directory,
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
    include ::barman::autoconfigure
  }
}
