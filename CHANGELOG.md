##2017-01-11 - Release 2.0.0

###Summary

Module update to support barman 2.x (thanks to Leo Antunes)

This release may break compatibility with puppet < 4

##2015-03-24 - Release 1.0.0
###Summary

Major improvements in autoconfiguration module.

This release changes the default value of `manage_package_repo`
parameter to `false`.

####Features
- Improved autoconfiguration module
- Improved documentation
- Enabled test suit again
- Enabled Travis CI

####Bugfixes
- #24 postgresql_server_id is not used consistently
- #25 Allow configuring $retention_policy in barman::postgres
- #26 postgres::globals shouldnt be defined in barman
