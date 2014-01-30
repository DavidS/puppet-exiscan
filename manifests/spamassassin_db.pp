# install and configure spamassassin database
class exiscan::spamassassin_db (
  $db_type        = postgres,
  $exim_ipaddress = '127.0.0.1',
  $db_name        = 'spamassassin',
  $db_username    = 'spamassassin',
  $db_password,) {
  validate_re($db_type, '^postgres$')

  case $db_type {
    'postgres' : {
      postgresql::dbcreate { $db_name:
        role     => $db_username,
        password => $db_password,
        address  => "${exim_ipaddress}/32",
        encoding => 'UTF8',
        locale   => 'en_US.UTF-8',
        template => "template0";
      }

      file {
        'spamassassin.opt.dir':
          ensure => directory,
          path   => '/opt/spamassassin',
          owner  => root,
          group  => root,
          mode   => 644;

        'spamassassin_3_2_2_initial.sql':
          ensure => present,
          path   => '/opt/spamassassin/spamassassin_3_2_2_initial.sql',
          owner  => root,
          group  => root,
          mode   => 644,
          source => 'puppet:///modules/exiscan/spamassassin/postgres/spamassassin_3_2_2_initial.sql',
      }

      postgresql::import { 'spamassassin_3_2_2_initial':
        source_url      => 'file:///opt/spamassassin/spamassassin_3_2_2_initial.sql',
        database        => $db_name,
        extract_command => false,
        user            => 'postgres',
        # object_owner    => $db_username,
        require         => [File['spamassassin_3_2_2_initial.sql'], Postgresql::Dbcreate[$db_name]],
      }
    }
  }
}
