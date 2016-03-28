# install and configure spamassassin
class exiscan::spamassassin (
  $trusted_networks     = $::ipaddress,
  $bayes_sql_dsn,
  $bayes_sql_username   = 'spamassassin',
  $bayes_sql_password   = 'spamassassin',
  $custom_rules_content = '',
  $custom_rules_source  = '') {

  $spamd_packages = ['spamassassin', 'libmail-dkim-perl', 'clamav-daemon', 'libclass-dbi-pg-perl', 'spf-tools-perl']

  package { $spamd_packages: ensure => installed; }

  service { ['spamassassin', 'clamav-freshclam', 'clamav-daemon']:
    ensure  => running,
    enable  => true,
    require => Package[$spamd_packages];
  }

  file {
    '/etc/default/spamassassin':
      ensure  => present,
      source  => 'puppet:///modules/exiscan/spamassassin/sa_default',
      mode    => '0644',
      owner   => root,
      group   => root,
      require => Package['spamassassin'],
      notify  => Service['spamassassin'];

    '/etc/spamassassin/local.cf':
      ensure  => present,
      content => template('exiscan/spamassassin.sa_local.cf.erb'),
      mode    => '0644',
      owner   => root,
      group   => root,
      require => Package['spamassassin'],
      notify  => Service['spamassassin'];

    '/etc/spamassassin/custom_rules.cf':
      ensure  => present,
      mode    => '0644',
      owner   => root,
      group   => root,
      require => Package['spamassassin'],
      notify  => Service['spamassassin'];

    '/var/run/spamd':
      ensure  => directory,
      mode    => '0750',
      owner   => 'debian-spamd',
      group   => 'debian-spamd',
      require => Package['spamassassin'],
      notify  => Service['spamassassin'];

    '/var/spool/exim4':
      ensure  => directory,
      mode    => '0750',
      owner   => 'Debian-exim',
      group   => 'clamav',
      require => [Package[exim], Package['clamav-daemon']],
      notify  => Service[exim];

    '/var/spool/exim4/scan':
      ensure  => directory,
      mode    => '2750',
      owner   => 'Debian-exim',
      group   => 'clamav',
      require => [Package[exim], Package['clamav-daemon']],
      notify  => Service[exim];

    '/etc/systemd/system/spamassassin.service':
      ensure  => present,
      source  => 'puppet:///modules/exiscan/spamassassin/spamassassin.service',
      mode    => '0644',
      owner   => root,
      group   => root,
      require => Package['spamassassin'],
      notify  => Service['spamassassin'];

    '/etc/systemd/system/multi-user.target.wants/spamassassin.service':
      ensure  => symlink,
      target  => '/etc/systemd/system/spamassassin.service',
      require => Package['spamassassin'],
      notify  => Service['spamassassin'];
  }

  if ($custom_rules_content != '') {
    File['/etc/spamassassin/custom_rules.cf'] {
      content => $custom_rules_content }
  }

  if ($custom_rules_source != '') {
    File['/etc/spamassassin/custom_rules.cf'] {
      source => $custom_rules_source }
  }
}
