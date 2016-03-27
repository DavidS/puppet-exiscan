require 'spec_helper'
require 'shared_contexts'

describe 'exiscan' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  
  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:master => false,
      #:sa_bayes_sql_local => false,
      :sa_bayes_sql_dsn => 'place_value_here',
      :sa_bayes_sql_username => 'place_value_here',
      #:sa_bayes_sql_password => "",
      #:sa_trusted_networks => $ipaddress,
      #:exim_source_dir => "",
      #:default_exim_sources => ["puppet:///modules/exiscan/default", "puppet:///modules/exiscan/scanner", "puppet:///modules/exiscan/greylist/exim4"],
      #:other_hostnames => [$::fqdn],
      #:relay_nets => [],
      #:relay_domains => ["@mx_any/ignore=+localhosts"],
      #:local_delivery => "mail_spool",
      #:listen_ipaddresses => ["::0", "0.0.0.0"],
      #:greylist_local => false,
      :greylist_dsn => 'place_value_here',
      :greylist_sql_username => 'place_value_here',
      #:greylist_sql_password => "",
      #:dkim_domain => $domain,
      #:dkim_private_key => undef,
      #:junk_submitters => [],
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_class('exim')
      .with(
        'package'          => 'exim4-daemon-heavy',
        'source_dir'       => '$exim_source_dir ? {  => $default_exim_sources, default => flatten([$exim_source_dir, $default_exim_sources]) }',
        'source_dir_purge' => 'true',
        'template'         => 'exiscan/update-exim4.conf.conf.erb'
      )
  end
  it do
    is_expected.to contain_class('exiscan::spamassassin')
      .with(
        'bayes_sql_dsn'      => '',
        'bayes_sql_password' => '',
        'bayes_sql_username' => '',
        'trusted_networks'   => '$ipaddress'
      )
  end
  it do
    is_expected.to contain_file('/etc/exim4/conf.d/main/01_exiscan_greylist_dsn')
      .with(
        'content' => 'GREYLIST_DSN = \\n',
        'group'   => 'Debian-exim',
        'mode'    => '0640',
        'owner'   => 'root'
      )
  end
  it do
    is_expected.to contain_file('/etc/exim4/conf.d/main/01_exiscan_dkim-options')
      .with(
        'content' => 'template(exiscan/dkim-options.erb)',
        'group'   => 'Debian-exim',
        'mode'    => '0644',
        'owner'   => 'root'
      )
  end
  it do
    is_expected.to contain_file('/etc/cron.daily/exiscan-junk-sync')
      .with(
        'content' => 'template(exiscan/junk-sync.erb)',
        'group'   => 'root',
        'mode'    => '0755',
        'owner'   => 'root'
      )
  end
  it do
    is_expected.to contain_class('exiscan::spamassassin_db')
      .with(
        'db_password' => '',
        'db_username' => ''
      )
  end
  it do
    is_expected.to contain_class('exiscan::greylist_db')
      .with(
        'db_password' => '',
        'db_username' => ''
      )
  end
  it do
    is_expected.to contain_file('/etc/exim4/dkim.private.key')
      .with(
        'group'  => 'Debian-exim',
        'mode'   => '0440',
        'owner'  => 'root',
        'source' => 'undef'
      )
  end
end
