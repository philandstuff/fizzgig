class webapp {
  nginx::site {'webapp':
  }
  file {'/etc/nginx/nginx.conf':
    ensure  => present,
    content => "fee fie foe fum",
  }
}
