# build the correct archive command
define barman::archive_command (
  $postgres_server_id  = 'default',
  $barman_user         = $::barman::settings::user,
  $barman_server       = $title,
  $barman_incoming_dir = '',
) {

  if $postgres_server_id == 'default'
  and $barman_incoming_dir == '' {
    fail "You must pass either postgres_server_id or barman_incoming_dir"
  }

  $real_barman_incoming_dir = $barman_incoming_dir ? {
    ''      => "${barman::settings::home}/${postgres_server_id}/incoming",
    default => $barman_incoming_dir,
  }

  postgresql::server::config_entry { "archive_command_${title}":
    value => "rsync -a %p ${barman_user}@${barman_server}:${real_barman_incoming_dir}/%f",
  }
}
