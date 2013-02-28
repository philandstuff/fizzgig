class webapp::config2 {
  $host = extlookup(extlookup('foo'))
  file{'/etc/webapp.conf':
    content => "mongo-host=$host\n",
  }
}
