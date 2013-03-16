class facts::template_test {
  file {'template-test':
    content => template('facts/template-test.erb'),
  }
}
