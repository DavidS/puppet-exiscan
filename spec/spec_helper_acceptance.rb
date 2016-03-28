require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Install this module
      copy_module_to(host, :source => proj_root, :module_name => 'exiscan')
      # List other dependencies here so they are installed on the host
      on host, puppet('module', 'install', 'example42-tinydata')
      # on host, puppet('module', 'install', 'example42-tp')
      install_dev_puppet_module( :source => './spec/fixtures/modules/tp', :module_name => 'tp' )
      on host, puppet('module', 'install', 'puppetlabs-stdlib')
      on host, puppet('module', 'install', 'ripienaar-concat')
    end
  end
end
