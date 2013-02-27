class webapp::config {
  $host = extlookup('mongo-host')
  file{'/etc/webapp.conf':
    content => "mongo-host=$host\n",
  }
}
