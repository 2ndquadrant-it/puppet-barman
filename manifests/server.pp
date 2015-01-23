# == Resource: barman::server
#
# This resource creates a barman configuration for a postgresql instance.
#
# NOTE: The resource is called in the 'postgres' class.
#
# === Parameters
#
# Many of the main configuration parameters can ( and *must*) be passed in order to
#  perform overrides.
#
# [*conninfo*] - Postgres connection string. *Mandatory*.
# [*ssh_command*] - Command to open an ssh connection to Postgres. *Mandatory*.
# [*ensure*] - Ensure (or not) that single server Barman configuration files are
#              created. The default value is 'present'. Just 'absent' or 'present'
#              are the possible settings.
# [*conf_template*] - path of the template file to build the Barman configuration
#                     file (the default value does not need to be changed).
# [*description*] - Description of the configuration file: it is automatically
#                   set when the resource is used.
# [*compression*] - Compression algorithm. Uses the global configuration
#                   if false (default).
# [*pre_backup_script*] - Script to launch before backups. Uses the global
#                         configuration if false (default).
# [*post_backup_script*] - Script to launch after backups. Uses the global
#                         configuration if false (default).
# [*immediate_checkpoint*] -  Force the checkpoint on the Postgres server to happen immediately and start your backup copy process as soon as possible. Disabled if false
#                          (default.)
# [*pre_archive_script*] - Script to launch before a WAL file is archived by maintenance. Disabled if false
#                          (default).
# [*post_archive_script*] - Script to launch after a WAL file is archived by maintenance. Disabled if false
#                          (default).
# [*custom_lines*] - Custom configuration directives (e.g. for custom
#                    compression). Defaults to empty.
#
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
# Copyright 2012-2014 2ndQuadrant Italia (Devise.IT SRL)
#
define barman::server (
  $conninfo,
  $ssh_command,
  $ensure               = 'present',
  $conf_template        = 'barman/server.conf.erb',
  $description          = $name,
  $compression          = false,
  $immediate_checkpoint = false,
  $pre_backup_script    = false,
  $post_backup_script   = false,
  $pre_archive_script   = false,
  $post_archive_scirpt  = false,
  $custom_lines         = undef,
) {

  # check if 'description' has been correctly configured
  validate_re($ensure, '^(present|absent)$', "${ensure} is not a valid value (ensure = present|absent).")

  # check if 'description' has been correctly configured
  validate_re($name, '^[0-9a-z\-/]*$', "${name} is not a valid name. Please only use lowercase letters, numbers, slashes and hyphens.")

  # check if immediate checkpoint is a boolean
  validate_bool($immediate_checkpoint)

  if $custom_lines != '' {
    notice "The 'custom_lines' option is deprecated. Please use \$conf_template for custom configuration"
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
