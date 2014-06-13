class barman::autoconfigure (
  $host_group     = $::barman::settings::host_group,
) {

  file { "${::barman::settings::home}/.pgpass":
    ensure  => 'file',
    owner   => $::barman::settings::user,
    group   => $::barman::settings::group,
    mode    => '0600',
    require => Class['barman'],
  }

  # Import Resources exported by Postgres Servers
  File_line <<| tag == "barman_pgpass_${host_group}" |>>
  Barman::Server <<| tag == "barman-${host_group}" |>> {
    barman_user => $::barman::settings::dbuser,
    require     => Class['barman'],
  }
  Cron <<| tag == "barman-${host_group}" |>> {
    require => Class['barman'],
  }
  Ssh_authorized_key <<| tag == "barman-${host_group}-postgresql" |>> {
    require => Class['barman'],
  }

  # Export resources to Postgres Servers
  @@barman::archive_command { $barman::barman_ipaddress:
    tag                 => "barman-${host_group}",
  }

  if ($::barman_key != undef and $::barman_key != '') {
    $barman_key_splitted = split($::barman_key, ' ')
    @@ssh_authorized_key { $barman::settings::user:
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
    database    => $barman::settings::dbname,
    user        => $barman::settings::dbuser,
    address     => "${barman::barman_ipaddress}/32",
    auth_method => 'md5',
    tag         => "barman-${host_group}",
  }

}
