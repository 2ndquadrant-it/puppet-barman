# == Class: barman
#
# This class installs Barman (Backup and recovery manager for Postgres).
#
# === Parameters
#
# [*home*] - A different place for backups than the default. Will be symlinked
#             to the default (/var/lib/barman).
#            You should not change this value after the first setup.
# [*logfile*] - A different log file. Default: /var/log/barman/barman.log
# [*compression*] - Compression algorithm. Currently supports 'gzip' (default),
#                    'bzip2', and 'custom'. Disabled if false.
# [*pre_backup_script*] - Script to launch before backups.
#                         Disabled if false (default).
# [*post_backup_script*] - Script to launch after backups.
#                         Disabled if false (default).
# [*custom_lines*] - Custom configuration directives (e.g. for custom
#                     compression). Defaults to empty.
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
#    home     => '/srv/barman',
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
  $user               = $barman::settings::user,
  $group              = $barman::settings::group,
  $ensure             = 'present',
  $conf_template      = 'barman/barman.conf',
  $logrotate_template = 'barman/logrotate.conf',
  $home               = $barman::settings::home,
  $logfile            = '/var/log/barman/barman.log',
  $compression        = 'gzip',
  $pre_backup_script  = false,
  $post_backup_script = false,
  $custom_lines       = '',
  $barman_ipaddress   = $::ipaddress,
  $autoconfigure      = $barman::settings::autoconfigure,
) inherits barman::settings {

  validate_bool($autoconfigure)

  $ensure_file = $ensure ? {
    'absent' => 'absent',
    default  => 'present',
  }

  $ensure_directory = $ensure ? {
    'absent' => 'absent',
    default  => 'directory',
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

  if $autoconfigure {
    include barman::autoconfigure
  }

}
