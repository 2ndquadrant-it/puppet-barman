# == Resource: barman::server
#
# This class creates a barman configuration for a postgresql instance
#
# === Parameters
#
# Many of the main configuration parameters can be passed in order to
#  perform overrides.
#
# [*conninfo*] - Postgres connection string. *Mandatory*.
# [*ssh_command*] - Command to open an ssh connection to Postgres. *Mandatory*.
# [*compression*] - Compression algorithm. Uses the global configuration
#                    if false (default).
# [*pre_backup_script*] - Script to launch before backups. Uses the global
#                           configuration if false (default).
# [*post_backup_script*] - Script to launch after backups. Uses the global
#                           configuration if false (default).
# [*custom_lines*] - Custom configuration directives (e.g. for custom
#                     compression). Defaults to empty.
#
# === Examples
#
#  barman::server { 'main':
#    conninfo    => 'user=postgres host=server1 password=pg123',
#    ssh_command => 'ssh postgres@server1',
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

define barman::server (
  $conninfo,
  $ssh_command,
  $description = $name,
  $compression = false,
  $pre_backup_script = false,
  $post_backup_script = false,
  $custom_lines = '',
) {

  validate_re($name, '^[0-9a-z\-/]*$', "${name} is not a valid name. Please only use lowercase letters, numbers, slashes and hyphens.")

  file { "/etc/barman.conf.d/${name}.conf":
    ensure  => present,
    mode    => '0640',
    owner   => 'root',
    group   => 'barman',
    content => template('barman/server.conf')
  }

  exec { "barman-check-${name}":
    command     => "barman check ${name} || true",
    provider    => shell,
    subscribe   => File["/etc/barman.conf.d/${name}.conf"],
    refreshonly => true
  }

}
