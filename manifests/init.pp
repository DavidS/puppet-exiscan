# primary class to connect the various parts of the configuration
class exiscan ($master = false) {
  $bool_master = any2bool($master)
  include exiscan::spamassassin

  class { 'exim': package => 'exim4-daemon-heavy'; }
}
