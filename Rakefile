require 'rubygems'

require 'bundler/setup'
Bundler.require :default

require 'puppetlabs_spec_helper/rake_tasks'

require 'puppet-lint/tasks/puppet-lint'

# Workaround for https://github.com/rodjek/puppet-lint/issues/331
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.disable_checks = ["80chars", "140chars"]
  config.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
  config.fail_on_warnings = true
  # Workaround for missing "relative" accessor
  #config.relative = true
  PuppetLint.configuration.relative = true
end
