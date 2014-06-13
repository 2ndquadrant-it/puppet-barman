# build the correct archive command
define barman::archive_command (
  $barman_home,
  $server,
  $barman_server = $title,
  $barman_user = 'barman',
) {

  postgresql::server::config_entry { 'archive_command':
    value => "rsync -a %p ${barman_user}@${barman_server}:${barman_home}/${server}/incoming/%f",
  }
}
