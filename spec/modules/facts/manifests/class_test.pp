class facts::class_test {
  notify {
    'unqualified-fact-test':
      message => $unqualified_fact;
    'qualified-fact-test':
      message => $::qualified_fact;
  }
  file {'template-test':
    content => template('facts/template-test.erb'),
  }
}
