define nginx::simple_server () {
  nginx::site{$title:
    content => template('nginx/vhost.erb'),
  }
}
