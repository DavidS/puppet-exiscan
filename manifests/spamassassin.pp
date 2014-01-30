# install and configure spamassassin
class exiscan::spamassassin (
  $trusted_networks     = $::ipaddress,
  $bayes_sql_dsn,
  $bayes_sql_username,
  $bayes_sql_password,
  $custom_rules_content = '',
  $custom_rules_source  = '') {
  package { [
    "spamassassin",
    "libmail-dkim-perl",
    "clamav-daemon",
    "libclass-dbi-pg-perl",
    "spf-tools-perl"]:
    ensure => installed;
  }

  service { ["spamassassin", "clamav-freshclam", "clamav-daemon"]:
    ensure => running,
    enable => true;
  }

  file {
    "/etc/default/spamassassin":
      ensure  => present,
      source  => "puppet:///modules/exiscan/spamassassin/sa_default",
      mode    => 0644,
      owner   => root,
      group   => root,
      require => Package["spamassassin"],
      notify  => Service["spamassassin"];

    "/etc/spamassassin/local.cf":
      ensure  => present,
      content => template("exiscan/spamassassin.sa_local.cf.erb"),
      mode    => 0644,
      owner   => root,
      group   => root,
      notify  => Service["spamassassin"];

    "/etc/spamassassin/custom_rules.cf":
      ensure => present,
      mode   => 0644,
      owner  => root,
      group  => root,
      notify => Service["spamassassin"];

    "/var/run/spamd":
      ensure  => directory,
      mode    => 0750,
      owner   => 'debian-spamd',
      group   => 'debian-spamd',
      require => Package["spamassassin"],
      notify  => Service["spamassassin"];

    "/var/spool/exim4":
      ensure  => directory,
      mode    => 0750,
      owner   => 'Debian-exim',
      group   => 'clamav',
      require => [Package["exim4"], Package["clamav-daemon"]],
      notify  => Service["exim4"];

    "/var/spool/exim4/scan":
      ensure  => directory,
      mode    => 2750,
      owner   => 'Debian-exim',
      group   => 'clamav',
      require => [Package["exim4"], Package["clamav-daemon"]],
      notify  => Service["exim4"];
  }

  if ($custom_rules_content != '') {
    File["/etc/spamassassin/custom_rules.cf"] {
      content => $custom_rules_content }
  }

  if ($custom_rules_source != '') {
    File["/etc/spamassassin/custom_rules.cf"] {
      source => $custom_rules_source }
  }
}