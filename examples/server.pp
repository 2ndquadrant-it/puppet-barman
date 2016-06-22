barman::server { 'main':
  conninfo    => 'user=test host=test password=test',
  ssh_command => 'ssh postgres@test'
}
