class barman::autoconfigure (
  $host_group = 'global',
) {

  file { '/var/lib/barman/.pgpass':
    ensure  => 'file',
    owner   => 'barman',
    group   => 'barman',
    mode    => '0600',
    require => Class['barman'],
  }

  # TODO: host specific password
  file_line { 'barman_pgpass_content':
    path   => '/var/lib/barman/.pgpass',
    line   => "*:*:*:barman-${::hostname}:${password}",
  }

  File_line <<| tag == "barman_pgpass_${host_group} |>>

  # export the archive command for target server usage
  @@barman_host::archive_command { $::fqdn:
    barman_home => $home,
    tag         => "barman-${host_group}",
  }

  # import resources from postgres servers
  Barman_host::Server_config <<| tag == "barman-${host_group}" |>> {
    barman_user => "barman-${::hostname}",
    require     => Class['barman'],
  }
  Cron <<| tag == "barman-${host_group}" |>> {
    require => Class['barman'],
  }
  Ssh_authorized_key <<| tag == "barman-${host_group}-postgresql" |>> {
    require => Class['barman'],
  }

  # export barman ssh key (avoid errors at first run)
  if ($::barman_key != undef and $::barman_key != '') {
    $barman_key_splitted = split($::barman_key, ' ')
    @@ssh_authorized_key { "barman-${::hostname}":
      ensure  => present,
      user    => 'postgres',
      type    => $barman_key_splitted[0],
      key     => $barman_key_splitted[1],
      tag     => "barman-${host_group}",
    }
  }

  @@postgresql::server::pg_hba_rule { "barman ${::hostname} client access":
    description => "barman ${::hostname} client access",
    type        => 'host',
    database    => 'postgres',
    user        => "barman-${::hostname}",
    address     => "${base_host::internal_ipaddress}/32",
    auth_method => 'md5',
    tag         => "barman-${host_group}",
  }

  @@postgresql::server::role { "barman-${::hostname}":
    login         => true,
    password_hash => postgresql_password("barman-${::hostname}", $password),
    superuser     => true,
    tag           => "barman-${host_group}",
  }

}
