define functions::define_test () {
  ssh_authorized_key{'barry':
    key => extlookup('ssh-key-barry'),
  }
}
