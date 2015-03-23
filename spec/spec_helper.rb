require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.mock_with :rspec do |mock|
    mock.syntax = [:expect, :should]
  end
  c.include PuppetlabsSpec::Files

  c.before :each do
    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables] = true
    end
  end

  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end
end
