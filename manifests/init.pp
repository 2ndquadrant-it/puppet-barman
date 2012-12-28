# == Class: barman
#
# This class installs BaRMan.
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
# The class can be used right away with the defaults:
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
#    pre_backup_script = '/usr/bin/touch /tmp/started',
#    post_backup_script = '/usr/bin/touch /tmp/stopped',
#    custom_lines = '; something'
#  }
# ---
#
# === Authors
#
# Alessandro Grassi <alessandro.grassi@devise.it>
#
# === Copyright
#
# Copyright 2012 Devise.IT SRL
#

class barman (
  $home = '/var/lib/barman',
  $logfile = '/var/log/barman/barman.log',
  $compression = 'gzip',
  $pre_backup_script = false,
  $post_backup_script = false,
  $custom_lines = ''
) {

  if $::osfamily == 'Debian' {
    include apt

    apt::source { 'apt-pgdg':
      location    => 'http://apt.postgresql.org/pub/repos/apt/',
      release     => "${::lsbdistcodename}-pgdg",
      repos       => 'main',
      key         => 'ACCC4CF8',
      key_source  => 'http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc',
      pin         => '500',
    }

    Apt::Source <| |> -> Package <| |>
  }

  package { 'barman':
    ensure  => latest
  }

  file { '/etc/barman.conf.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'barman',
    mode    => '0750',
    require => Package['barman'],
  }

  file { '/etc/barman.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'barman',
    mode    => '0640',
    content => template('barman/barman.conf'),
    require => File['/etc/barman.conf.d'],
  }

  file { $home:
    ensure  => directory,
    owner   => 'barman',
    group   => 'barman',
    mode    => '0750',
    require => Package['barman']
  }

  exec { 'barman-check-all':
    command     => '/usr/bin/barman check all',
    subscribe   => File[$home],
    refreshonly => true
  }

  file { '/etc/logrotate.d/barman':
    ensure  => present,
    owner   => 'root',
    group   => 'barman',
    mode    => '0644',
    content => template('barman/logrotate.conf'),
    require => Package['barman']
  }

}
