require 'spec_helper'
require 'shared_contexts'

describe 'exiscan::spamassassin' do
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
      #:trusted_networks => $ipaddress,
      :bayes_sql_dsn => 'place_value_here',
      #:bayes_sql_username => "spamassassin",
      #:bayes_sql_password => "spamassassin",
      #:custom_rules_content => "",
      #:custom_rules_source => "",
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_package('[spamassassin, libmail-dkim-perl, clamav-daemon, libclass-dbi-pg-perl, spf-tools-perl]')
      .with(
        'ensure' => 'installed'
      )
  end
  it do
    is_expected.to contain_service('[spamassassin, clamav-freshclam, clamav-daemon]')
      .with(
        'enable'  => 'true',
        'ensure'  => 'running',
        'require' => 'Package[$spamd_packages]'
      )
  end
  it do
    is_expected.to contain_file('/etc/default/spamassassin')
      .with(
        'ensure'  => 'present',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Service[spamassassin]',
        'owner'   => 'root',
        'require' => 'Package[spamassassin]',
        'source'  => 'puppet:///modules/exiscan/spamassassin/sa_default'
      )
  end
  it do
    is_expected.to contain_file('/etc/spamassassin/local.cf')
      .with(
        'content' => 'template(exiscan/spamassassin.sa_local.cf.erb)',
        'ensure'  => 'present',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Service[spamassassin]',
        'owner'   => 'root',
        'require' => 'Package[spamassassin]'
      )
  end
  it do
    is_expected.to contain_file('/etc/spamassassin/custom_rules.cf')
      .with(
        'ensure'  => 'present',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Service[spamassassin]',
        'owner'   => 'root',
        'require' => 'Package[spamassassin]'
      )
  end
  it do
    is_expected.to contain_file('/var/run/spamd')
      .with(
        'ensure'  => 'directory',
        'group'   => 'debian-spamd',
        'mode'    => '0750',
        'notify'  => 'Service[spamassassin]',
        'owner'   => 'debian-spamd',
        'require' => 'Package[spamassassin]'
      )
  end
  it do
    is_expected.to contain_file('/var/spool/exim4')
      .with(
        'ensure'  => 'directory',
        'group'   => 'clamav',
        'mode'    => '0750',
        'notify'  => 'Service[exim4]',
        'owner'   => 'Debian-exim',
        'require' => '[Package[$exim::package], Package[clamav-daemon]]'
      )
  end
  it do
    is_expected.to contain_file('/var/spool/exim4/scan')
      .with(
        'ensure'  => 'directory',
        'group'   => 'clamav',
        'mode'    => '2750',
        'notify'  => 'Service[exim4]',
        'owner'   => 'Debian-exim',
        'require' => '[Package[$exim::package], Package[clamav-daemon]]'
      )
  end
  it do
    is_expected.to contain_file('/etc/systemd/system/spamassassin.service')
      .with(
        'ensure'  => 'present',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Service[spamassassin]',
        'owner'   => 'root',
        'require' => 'Package[spamassassin]',
        'source'  => 'puppet:///modules/exiscan/spamassassin/spamassassin.service'
      )
  end
  it do
    is_expected.to contain_file('/etc/systemd/system/multi-user.target.wants/spamassassin.service')
      .with(
        'ensure'  => 'symlink',
        'notify'  => 'Service[spamassassin]',
        'require' => 'Package[spamassassin]',
        'target'  => '/etc/systemd/system/spamassassin.service'
      )
  end
end
