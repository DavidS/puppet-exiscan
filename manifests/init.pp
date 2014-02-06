# primary class to connect the various parts of the configuration
class exiscan (
  $master                = false,
  $sa_bayes_sql_local    = false,
  $sa_bayes_sql_dsn,
  $sa_bayes_sql_username,
  $sa_bayes_sql_password = '',
  $exim_source_dir       = '',
  $other_hostnames       = [$::fqdn],
  $relay_nets            = [],
  $relay_domains         = ["@mx_any/ignore=+localhosts"],
  $local_delivery        = 'mail_spool',
  $listen_ipaddresses    = ['::0', '0.0.0.0'],
  $greylist_local        = false,
  # 'servers={hostname}/{database}/{user}[/{password}]'
  $greylist_dsn,
  $greylist_sql_username,
  $greylist_sql_password = '',
  $dkim_domain           = $::domain) {
  validate_bool($master)
  validate_bool($sa_bayes_sql_local)
  validate_bool($greylist_local)

  $exim_sources = $exim_source_dir ? {
    ''      => ["puppet:///modules/exiscan/default", "puppet:///modules/exiscan/scanner"],
    default => [$exim_source_dir, "puppet:///modules/exiscan/default", "puppet:///modules/exiscan/scanner"]
  }

  class {
    'exim':
      package          => 'exim4-daemon-heavy',
      template         => 'exiscan/update-exim4.conf.conf.erb',
      source_dir       => $exim_sources,
      source_dir_purge => true;

    'exiscan::spamassassin':
      bayes_sql_dsn      => $sa_bayes_sql_dsn,
      bayes_sql_username => $sa_bayes_sql_username,
      bayes_sql_password => $sa_bayes_sql_password;
  }

  if ($sa_bayes_sql_local) {
    class { 'exiscan::spamassassin_db':
      db_username => $sa_bayes_sql_username,
      db_password => $sa_bayes_sql_password;
    }
    Package["spamassassin"] -> Class['exiscan::spamassassin_db'] -> Service["spamassassin"]
  }

  if ($greylist_local) {
    class { 'exiscan::greylist_db':
      db_username => $greylist_sql_username,
      db_password => $greylist_sql_password;
    }
    Package[$exim::package] -> Class['exiscan::greylist_db'] -> Service['exim']
  }

  # workaround debianism/systemd fail
  # update-exim4.conf failures are not recognized by the default module
  File['exim.dir'] ~> exec { "/usr/sbin/update-exim4.conf":
    refreshonly => true,
    logoutput   => on_failure;
  } ~> Service['exim']

  file {
    "/etc/exim4/conf.d/main/01_exiscan_greylist_dsn":
      content => "GREYLIST_DSN = ${greylist_dsn}\n",
      mode    => 0640,
      owner   => root,
      group   => 'Debian-exim';

    "/etc/exim4/conf.d/main/01_exiscan_dkim-options":
      content => template("exiscan/dkim-options.erb"),
      mode    => 0644,
      owner   => root,
      group   => 'Debian-exim';
  }
}
