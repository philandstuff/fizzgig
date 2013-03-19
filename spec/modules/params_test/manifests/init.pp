define params_test ($param, $param_with_default = 'default_val') {
  file {"${title}-param":
    source => $param,
  }
  notify {"${title}-default":
    message => $param_with_default,
  }
}
