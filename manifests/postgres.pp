class barman::postgres (
  $host_group     = $::barman::settings::host_group,
  $wal_level      = 'archive',
  $barman_user    = $::barman::settings::user,
  $barman_dbuser  = $::barman::settings::dbuser,
  $barman_dbname  = $::barman::settings::dbname,
  $backup_wday    = undef,
  $backup_hour    = 4,
  $backup_minute  = 0,
  $password       = '',
  $server_address = $::fqdn,
  $postgres_server_id = $::hostname,
) inherits ::barman::settings {

  unless defined(Class['postgresql::server']) {
    fail('barman::server requires the postgresql::server module installed and configured')
  }

  $real_password = $password ? {
    ''      => fqdn_rand('30','fwsfbsfw'),
    default => $password,
  }

  # configure server for archive mode
  postgresql::server::config_entry {
    'archive_mode': value => 'on';
    'wal_level': value => "${wal_level}";
  }

  postgresql::server::role { $barman_dbuser:
    login         => true,
    password_hash => postgresql_password($barman_dbuser, $real_password),
    superuser     => true,
  }

  # Collect resources exported by Barman server
  Barman::Archive_command <<| tag == "barman-${host_group}" |>> {
    postgres_server_id => $postgres_server_id,
  }
  Postgresql::Server::Pg_hba_rule <<| tag == "barman-${host_group}" |>>
  Ssh_authorized_key <<| tag == "barman-${host_group}" |>> {
    require => Class['postgresql::server'],
  }

  # Export resources to Barman server
  @@barman::server { $::hostname:
    conninfo    => "user=${barman_dbuser} dbname=${barman_dbname} host=${server_address}",
    ssh_command => "ssh ${barman_user}@${server_address}",
    tag         => "barman-${host_group}",
  }

  @@cron { "barman_backup_${::hostname}":
    command    => "[ -x /usr/bin/barman ] && /usr/bin/barman -q backup ${::hostname}",
    user       => 'root',
    weekday    => $backup_wday,
    hour       => $backup_hour,
    minute     => $backup_minute,
    tag        => "barman-${host_group}",
  }

  @@file_line { "barman_pgpass_content-${::hostname}":
    path   => "${::barman::settings::barman_home}/.pgpass",
    line   => "${server_address}:*:${barman_dbname}:${barman_dbuser}:${real_password}",
    tag    => "barman-${host_group}",
  }

  if ($::postgres_key != undef and $::postgres_key != '') {
    $postgres_key_splitted = split($::postgres_key, ' ')
    @@ssh_authorized_key { "postgres-${::hostname}":
      ensure  => present,
      user    => $barman_user,
      type    => $postgres_key_splitted[0],
      key     => $postgres_key_splitted[1],
      tag     => "barman-${host_group}-postgresql",
    }
  }

}
