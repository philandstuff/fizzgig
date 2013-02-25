define nginx::site () {
  file {"/etc/nginx/sites-enabled/$title":
    ensure => present,
  }
}
