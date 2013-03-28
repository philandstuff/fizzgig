class functions::function_with_multiple_arguments {
  file {'/tmp/multiarg_fn_test':
    content => hiera('hiera_key','default value');
  }
}
