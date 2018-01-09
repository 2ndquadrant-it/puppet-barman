## 2018-01-09 - Release 2.1.0

### Summary

- Improved hiera support
- Added support for `backup_directory`, `log_level` and `parallel_cron_jobs`
- Added support for SSH host key exchange
- Updated module dependencies to need newer postgresql and apt modules

#### Bugfixes

- #38, #48 Make pg_hba_rule title server-specific to avoid duplication
- Added settings that were left behind to the template
- Only set `archive_command` if archiving is enabled
- Avoid exchanging ssh authentication keys if the setup is streaming only

## 2017-03-16 - Release 2.0.2

### Summary

Add support for recovery_options setting

## 2017-02-06 - Release 2.0.1

### Summary
Fixed a couple outstanding bugs.
Thanks to mzsamantha and James Miller.

#### Bugfixes

- streaming_conninfo missing from server template
- allow _ in server names

## 2017-01-11 - Release 2.0.0

### Summary

Module update to support barman 2.x (thanks to Leo Antunes)

This release may break compatibility with puppet < 4

## 2015-03-24 - Release 1.0.0

### Summary

Major improvements in autoconfiguration module.

This release changes the default value of `manage_package_repo`
parameter to `false`.

#### Features
- Improved autoconfiguration module
- Improved documentation
- Enabled test suit again
- Enabled Travis CI

#### Bugfixes
- #24 postgresql_server_id is not used consistently
- #25 Allow configuring $retention_policy in barman::postgres
- #26 postgres::globals shouldnt be defined in barman
