define nginx::site ($content) {
  file {"/etc/nginx/sites-enabled/$title":
    ensure  => present,
    mode    => 0440,
    content => template('nginx/vhost.erb'),
  }
  user {'www-data':
  }
}
