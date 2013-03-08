define facts::define_test() {
  notify {
    'unqualified-fact-test':
      message => $unqualified_fact;
    'qualified-fact-test':
      message => $::qualified_fact;
  }
}
