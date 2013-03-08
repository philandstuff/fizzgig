class functions::recursive_extlookup_test {
  ssh_authorized_key{'barry':
    key => extlookup(extlookup('ssh-key-barry')),
  }
}
