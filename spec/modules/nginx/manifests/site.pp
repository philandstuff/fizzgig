define nginx::site ($message = 'asdf') {
  file {"/etc/nginx/sites-enabled/$title":
    ensure  => present,
    mode    => 0440,
    content => template('nginx/vhost.erb'),
  }
  notify{'nginx message':
    message => $message,
  }
  nginx::wibble{'foo':}
}
