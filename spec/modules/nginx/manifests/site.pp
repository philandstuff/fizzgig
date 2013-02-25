define nginx::site () {
  file {"/etc/nginx/sites-enabled/$title":
    ensure => present,
    mode   => 0440,
  }
  notify{'different resource type':}
}
