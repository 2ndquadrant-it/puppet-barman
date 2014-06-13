class barman::postgres (
  $host_group     = 'global',
  $wal_level      = 'archive',
  $barman_user    = 'barman',
  $backup_wday    = undef,
  $backup_hour    = 4,
  $backup_minute  = 0,
) {

  unless defined(Class['postgresql::server']) {
    fail('barman::server requires the postgresql::server module installed and configured')
  }

  # configure server for archive mode
  postgresql::server::config_entry {
    'archive_mode': value => 'on';
    'wal_level': value => $wal_level;
  }

  # configure the archive command
  Barman::Archive_command <<| tag == "barman-${host_group}" |>> {
    server => $::hostname,
  }

  # allow connection from the Barman server
  Postgresql::Server::Pg_hba_rule <<| tag == "barman-${host_group}" |>>
  Postgresql::Server::Role <<| tag == "barman-${host_group}" |>>
  Ssh_authorized_key <<| tag == "barman-${host_group}" |>> {
    require => Class['postgresql::server'],
  }

  # barman server configuration
  @@barman::server_config { $::hostname:
    server_address => $::fqdn,
    tag            => "barman-${host_group}",
  }

  # export cron line definition
  @@cron { "barman_daily_backup_${::hostname}":
    command    => "[ -x /usr/bin/barman ] && /usr/bin/barman -q backup ${::hostname}",
    user       => 'root',
    weekday    => $backup_wday,
    hour       => $backup_hour,
    minute     => $backup_minute,
    tag        => "barman-${host_group}",
  }

  # export pgpass file line
  @@file_line { "barman_pgpass_content-${::hostname}":
    path   => '/var/lib/barman/.pgpass',
    line   => "*:*:*:barman-${::hostname}:",
    tag    => "barman-${host_group}",
  }

  # export postgres ssh key (avoid errors at first run)
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
