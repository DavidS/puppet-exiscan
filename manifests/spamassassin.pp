# install and configure spamassassin
class exiscan::spamassassin {
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
    "/var/run/spamd":
      ensure => directory,
      mode   => 0750,
      owner  => 'debian-spamd',
      group  => 'debian-spamd',
      before => Service["spamassassin"];

    "/var/spool/exim4":
      ensure => directory,
      mode   => 0750,
      owner  => 'Debian-exim',
      group  => 'clamav',
      before => Service["exim4"];

    "/var/spool/exim4/scan":
      ensure => directory,
      mode   => 2750,
      owner  => 'Debian-exim',
      group  => 'clamav',
      before => Service["exim4"];
  }

}