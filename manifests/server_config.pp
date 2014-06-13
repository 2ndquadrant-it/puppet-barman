define barman::server_config (
  $server_address,
  $server_name = $title,
  $dbname      = 'postgres',
  $dbuser      = 'postgres',
) {

  # barman server configuration
  barman::server { $server_name:
    conninfo    => "user=${dbuser} dbname=${dbname} host=${server_address}",
    ssh_command => "ssh ${dbuser}@${server_address}",
  }

}
