# 0.2.0

  * Changed function stubs to allow multi-arg functions. This broke
existing code, since single args need to be wrapped in an Array.

# 0.1.1

  * fixed bug to allow multiple conditions on a matcher, eg:
```ruby
  it {should contain_file('foo').with_content(/asdf/).with_content(/jkl;/)}
```


# 0.1.0

  * Initial release
