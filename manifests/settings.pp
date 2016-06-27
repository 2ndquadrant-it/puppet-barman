# == Class: barman
#
# This class just contains default settings for the 'barman'
# Puppet module.
#
# NOTE: Parameters can be changed passing values by Hiera file.
#
# === Parameters
#
# [*user*] - The Barman user. The default value is 'barman'.
# [*group*] - The group of the Barman user. The default
#             value is 'barman'.
# [*dbuser*] - The user used by Barman to connect to
#              PostgreSQL database(s). It will be used to
#              build the 'conninfo' Barman parameter.
#              The default value is 'barman', and will be
#              the same for all the PostgreSQL servers.
# [*dbname*] - The database where Barman can connect. It will
#              be used to build the 'conninfo' Barman parameter.
#              The default one is the 'postgres' database.
# [*home*] - The Barman user home directory. The default
#            value is '/var/lib/barman', but it can be changed
#            depending on the operating system.
# [*autoconfigure*] - This is the main parameter to enable the
#                     autoconfiguration of the backup of a
#                     given postgreSQL server performed by
#                     Barman.
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
class barman::settings (
  $user                    = 'barman',
  $group                   = 'barman',
  $dbuser                  = 'barman',
  $dbname                  = 'postgres',
  $home                    = '/var/lib/barman',
  $logfile                 = '/var/log/barman/barman.log',
  $compression             = 'gzip',
  $immediate_checkpoint    = false,
  $pre_backup_script       = false,
  $post_backup_script      = false,
  $pre_archive_script      = false,
  $post_archive_script     = false,
  $basebackup_retry_times  = false,
  $basebackup_retry_sleep  = false,
  $backup_options          = 'exclusive_backup',
  $minimum_redundancy      = '0',
  $last_backup_maximum_age = false,
  $retention_policy        = '',
  $retention_policy_mode   = 'auto',
  $wal_retention_policy    = 'main',
  $reuse_backup            = false,
  $custom_lines            = '',
  $autoconfigure           = false,
  $host_group              = 'global',
  $manage_package_repo     = false,
  $purge_unknown_conf      = false,
) {

}
