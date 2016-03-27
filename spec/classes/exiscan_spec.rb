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
    {
      concat_basedir: '/tmp/concat',
      ipaddress: '10.0.0.1',
      operatingsystem: 'Debian',
      operatingsystemrelease: '8.0',
      osfamily: 'Debian',
      puppetversion: '4.4.1',
    }
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:master => false,
      #:sa_bayes_sql_local => false,
      :sa_bayes_sql_dsn => 'sa_bayes_sql_dsn_value',
      :sa_bayes_sql_username => 'sa_bayes_sql_username_value',
      :sa_bayes_sql_password => 's3cr3t',
      #:sa_trusted_networks => $ipaddress,
      #:exim_source_dir => "",
      #:default_exim_sources => ["puppet:///modules/exiscan/default", "puppet:///modules/exiscan/scanner", "puppet:///modules/exiscan/greylist/exim4"],
      #:other_hostnames => [$::fqdn],
      #:relay_nets => [],
      #:relay_domains => ["@mx_any/ignore=+localhosts"],
      #:local_delivery => "mail_spool",
      #:listen_ipaddresses => ["::0", "0.0.0.0"],
      #:greylist_local => false,
      :greylist_dsn => 'greylist_dsn_value',
      :greylist_sql_username => 'greylist_sql_username_value',
      #:greylist_sql_password => "",
      #:dkim_domain => $domain,
      #:dkim_private_key => undef,
      #:junk_submitters => [],
    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_tp__install('exim')
      .with(
        settings_hash: { 'package_name' => 'exim4-daemon-heavy' }
      )
  end
  it do
    is_expected.to contain_class('exiscan::spamassassin')
      .with(
        'bayes_sql_dsn'      => 'sa_bayes_sql_dsn_value',
        'bayes_sql_password' => 's3cr3t',
        'bayes_sql_username' => 'sa_bayes_sql_username_value',
        'trusted_networks'   => '10.0.0.1'
      )
  end
  it do
    is_expected.to contain_file('/etc/exim4/conf.d/main/01_exiscan_greylist_dsn')
      .with(
        'content' => "GREYLIST_DSN = greylist_dsn_value\n",
        'group'   => 'Debian-exim',
        'mode'    => '0640',
        'owner'   => 'root'
      )
  end
  it do
    is_expected.to contain_file('/etc/exim4/conf.d/main/01_exiscan_dkim-options')
      .with(
        'group'   => 'Debian-exim',
        'mode'    => '0644',
        'owner'   => 'root'
      )
  end
  it do
    is_expected.to contain_file('/etc/cron.daily/exiscan-junk-sync')
      .with(
        'group'   => 'root',
        'mode'    => '0755',
        'owner'   => 'root'
      )
  end

  context 'without a local sa_bayes db' do
    # sa_bayes_sql_local = false is default
    it do
      is_expected.not_to contain_class('exiscan::spamassassin_db')
    end
  end

  context 'with a local sa_bayes db' do
    let(:params) do
      super().merge({
        sa_bayes_sql_local: true
      })
    end
    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_class('exiscan::spamassassin_db')
        .with(
          'db_password' => 's3cr3t',
          'db_username' => 'sa_bayes_sql_username_value'
        )
    end
  end

  context 'without a local greylist db' do
    # greylist_local = false is default
    it do
      is_expected.not_to contain_class('exiscan::greylist_db')
    end
  end

  context 'with a local greylist db' do
    let(:params) do
      super().merge({
        greylist_local: true
      })
    end
    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_class('exiscan::greylist_db')
        .with(
          'db_password' => '',
          'db_username' => 'greylist_sql_username_value'
        )
    end
  end

  context 'without a local dkim private key' do
    # greylist_local = false is default
    it do
      is_expected.not_to contain_file('/etc/exim4/dkim.private.key')
    end
  end

  context 'with a local dkim private key' do
    let(:params) do
      super().merge({
        dkim_private_key: 'puppet:///modules/site/dkim.private.key'
      })
    end
    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_file('/etc/exim4/dkim.private.key')
        .with(
          'group'  => 'Debian-exim',
          'mode'   => '0440',
          'owner'  => 'root',
          'source' => 'puppet:///modules/site/dkim.private.key'
        )
    end
  end

  describe 'exiscan::spamassassin' do
    # add these two lines in a single test block to enable puppet and hiera debug mode
    # Puppet::Util::Log.level = :debug
    # Puppet::Util::Log.newdestination(:console)
    ['spamassassin', 'libmail-dkim-perl', 'clamav-daemon', 'libclass-dbi-pg-perl', 'spf-tools-perl'].each do |p|
      it { is_expected.to contain_package(p).with('ensure' => 'installed') }
    end
    ['spamassassin', 'clamav-freshclam', 'clamav-daemon'].each do |s|
      it do
        is_expected.to contain_service(s)
          .that_requires(['spamassassin', 'libmail-dkim-perl', 'clamav-daemon', 'libclass-dbi-pg-perl', 'spf-tools-perl'].collect {|p| "Package[#{p}]" })
          .with(
            'enable'  => 'true',
            'ensure'  => 'running',
        )
      end
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
          # 'content' => 'template(exiscan/spamassassin.sa_local.cf.erb)',
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
        .that_requires(['Package[exim]', 'Package[clamav-daemon]'])
        .that_notifies('Service[exim]')
        .with(
          'ensure'  => 'directory',
          'group'   => 'clamav',
          'mode'    => '0750',
          'owner'   => 'Debian-exim',
        )
    end
    it do
      is_expected.to contain_file('/var/spool/exim4/scan')
        .that_requires(['Package[exim]', 'Package[clamav-daemon]'])
        .that_notifies('Service[exim]')
        .with(
          'ensure'  => 'directory',
          'group'   => 'clamav',
          'mode'    => '2750',
          'owner'   => 'Debian-exim',
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
end
