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
# * Alessandro Grassi <alessandro.grassi@2ndQuadrant.it>
#
# Many thanks to Alessandro Franceschi <al@lab42.it>
#
# === Copyright
#
# Copyright 2012-2017 2ndQuadrant Italia
#
class barman::settings (
  $user                          = 'barman',
  $group                         = 'barman',
  $dbuser                        = 'barman',
  $dbname                        = 'postgres',
  $home                          = '/var/lib/barman',
  $home_mode                     = '0750',
  $archiver                      = true,
  $archiver_batch_size           = undef,
  $backup_method                 = undef,
  $backup_options                = 'exclusive_backup',
  $bandwidth_limit               = undef,
  $basebackup_retry_sleep        = false,
  $basebackup_retry_times        = false,
  $check_timeout                 = undef,
  $custom_compression_filter     = undef,
  $custom_decompression_filter   = undef,
  $compression                   = 'gzip',
  $immediate_checkpoint          = false,
  $last_backup_maximum_age       = false,
  $logfile                       = '/var/log/barman/barman.log',
  $log_level                     = undef,
  $minimum_redundancy            = '0',
  $network_compression           = undef,
  $parallel_jobs                 = undef,
  $path_prefix                   = undef,
  $post_archive_retry_script     = false,
  $post_archive_script           = false,
  $post_backup_retry_script      = false,
  $post_backup_script            = false,
  $pre_archive_retry_script      = false,
  $pre_archive_script            = false,
  $pre_backup_retry_script       = false,
  $pre_backup_script             = false,
  $recovery_options              = undef,
  $retention_policy              = '',
  $retention_policy_mode         = 'auto',
  $reuse_backup                  = false,
  $slot_name                     = undef,
  $streaming_archiver            = false,
  $streaming_archiver_batch_size = undef,
  $streaming_archiver_name       = undef,
  $streaming_backup_name         = undef,
  $tablespace_bandwidth_limit    = undef,
  $wal_retention_policy          = 'main',
  $custom_lines                  = '',
  $autoconfigure                 = false,
  $host_group                    = 'global',
  $manage_package_repo           = false,
  $manage_ssh_host_keys          = false,
  $purge_unknown_conf            = false,
) {

}
