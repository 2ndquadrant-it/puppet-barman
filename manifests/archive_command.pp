# == Class: archive_command
#
# Build the correct archive command which will be exported to the PostgreSQL server
#
# === Parameters
#
# [*postgres_server_id*] - Tag for the PostgreSQL server. The default value (the host name)
#                          should be fine, so you don't need to change this.
# [*barman_user*] - The default value is the one contained in the 'settings' class.
# [*barman_server*] - The value is set when the resource is created
#                     (in the 'autoconfigure' class).
# [*barman_incoming_dir*] - The Barman WAL incoming directory. The default value will be
#                           generated here to be something like
#                           '<barman home>/<postgres_server_id>/incoming'
#
# All parameters that are supported can be changed when the resource 'archive' is
# created in the 'autoconfigure' class.
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
define barman::archive_command (
  $postgres_server_id  = 'default',
  $barman_user         = $::barman::settings::user,
  $barman_server       = $title,
  $barman_home         = $barman::settings::home,
  $barman_incoming_dir = '',
) {

  # Ensure that 'postgres' class correctly configure the 'archive_command'
  if $postgres_server_id == 'default'
  and $barman_incoming_dir == '' {
    fail 'You must pass either postgres_server_id or barman_incoming_dir'
  }

  # Generate path if not explicitely defined
  $real_barman_incoming_dir = $barman_incoming_dir ? {
    ''      => "${barman_home}/${postgres_server_id}/incoming",
    default => $barman_incoming_dir,
  }

  postgresql::server::config_entry { "archive_command_${title}":
    name  => 'archive_command',
    value => "rsync -a %p ${barman_user}@${barman_server}:${real_barman_incoming_dir}/%f",
  }
}
