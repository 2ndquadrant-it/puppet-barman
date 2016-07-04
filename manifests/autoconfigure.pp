# == Class: barman
#
# This class:
#
# * Creates the .pgpass file for the 'barman' user
# * Imports resources exported by PostgreSQL server
# ** to set cron
# ** to import SSH key of 'postgres' user
# ** to fill the .pgpass file
# ** to configure Barman (fill .conf files)
# * Exports Barman resources to the PostgreSQL server
# ** to set the 'archive_command' in postgresql.conf
# ** to export the SSH key of 'barman' user
# ** to configure the pg_hba.conf
#
# === Parameters
#
# [*host_group*] - Tag the different host groups for the backup
#                  (default value is set from the 'settings' class).
# [*exported_ipaddress*] - The barman server address to allow in the PostgreSQL
#                          server ph_hba.conf. Defaults to "${::ipaddress}/32".
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
class barman::autoconfigure (
  $host_group         = $::barman::settings::host_group,
  $exported_ipaddress = "${::ipaddress}/32",
) {

  # create the (empty) .pgpass file
  file { "${::barman::settings::home}/.pgpass":
    ensure  => 'file',
    owner   => $::barman::settings::user,
    group   => $::barman::settings::group,
    mode    => '0600',
    require => Class['barman'],
  }

  ############ Import Resources exported by Postgres Servers

  # This fill the .pgpass file
  File_line <<| tag == "barman-${host_group}" |>>

  # Import all needed information for the 'server' class
  Barman::Server <<| tag == "barman-${host_group}" |>> {
    require     => Class['barman'],
  }

  # Add crontab
  Cron <<| tag == "barman-${host_group}" |>> {
    require => Class['barman'],
  }

  # Import 'postgres' key
  Ssh_authorized_key <<| tag == "barman-${host_group}-postgresql" |>> {
    require => Class['barman'],
  }

  ############## Export resources to Postgres Servers

  # export the archive command
  @@barman::archive_command { $::barman::barman_fqdn :
    tag         => "barman-${host_group}",
    barman_home => $barman::home,
  }

  # export the 'barman' SSH key - create if not present
  if ($::barman_key != undef and $::barman_key != '') {
    $barman_key_splitted = split($::barman_key, ' ')
    @@ssh_authorized_key { $barman::settings::user:
      ensure => present,
      user   => 'postgres',
      type   => $barman_key_splitted[0],
      key    => $barman_key_splitted[1],
      tag    => "barman-${host_group}",
    }
  }

  # export configuration for the pg_hba.conf
  @@postgresql::server::pg_hba_rule { "barman ${::hostname} client access":
    description => "barman ${::hostname} client access",
    type        => 'host',
    database    => $barman::settings::dbname,
    user        => $barman::settings::dbuser,
    address     => $exported_ipaddress,
    auth_method => 'md5',
    tag         => "barman-${host_group}",
  }

}
