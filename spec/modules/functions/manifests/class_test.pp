class functions::class_test {
  ssh_authorized_key{'barry':
    key => extlookup('ssh-key-barry'),
  }
}
