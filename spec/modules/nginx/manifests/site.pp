define nginx::site () {
  file {"/etc/nginx/sites-enabled/$title":
    ensure  => present,
    mode    => 0440,
    content => template('nginx/vhost.erb'),
  }
  notify{'different resource type':}
  nginx::wibble{'foo':}
}
