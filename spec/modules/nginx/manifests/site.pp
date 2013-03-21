define nginx::site () {
  file {"/etc/nginx/sites-available/$title":
    ensure  => present,
    content => template('nginx/vhost.erb'),
  }
  file {"/etc/nginx/sites-enabled/$title":
    ensure  => link,
    target  => "/etc/nginx/sites-available/${title}",
  }
}
