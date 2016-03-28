# install and configure spamassassin database
class exiscan::spamassassin_db (
  $db_type        = postgres,
  $exim_ipaddress = '127.0.0.1',
  $db_name        = 'spamassassin',
  $db_username    = 'debian-spamd',
  $db_password,) {
  validate_re($db_type, '^postgres$')

  $runtime_user = $db_username

  case $db_type {
    'postgres' : {
      postgresql::dbcreate { $db_name:
        role     => $db_username,
        password => $db_password,
        address  => "${exim_ipaddress}/32",
        encoding => 'UTF8',
        locale   => 'en_US.UTF-8',
        template => 'template0';
      }

      file {
        '/var/lib/spamd-dbimport':
          ensure => directory,
          mode   => '0700',
          owner  => $runtime_user;

        'spamassassin_3_2_2_initial.sql':
          ensure => present,
          path   => '/var/lib/spamd-dbimport/spamassassin_3_2_2_initial.sql',
          owner  => root,
          group  => root,
          mode   => '0644',
          source => 'puppet:///modules/exiscan/spamassassin/postgres/spamassassin_3_2_2_initial.sql',
      }

      postgresql::import { 'spamassassin_3_2_2_initial':
        source_url      => 'file:///var/lib/spamd-dbimport/spamassassin_3_2_2_initial.sql',
        database        => $db_name,
        extract_command => false,
        user            => $runtime_user,
        log             => '/var/lib/spamd-dbimport/log',
        errorlog        => '/var/lib/spamd-dbimport/errorlog',
        flagfile        => '/var/lib/spamd-dbimport/flagfile',
        require         => [File['spamassassin_3_2_2_initial.sql'], Postgresql::Dbcreate[$db_name]],
      }
    }
    default: {
      fail("Database type ${db_type} not supported")
    }
  }
}
