# 0.1.1

  * fixed bug to allow multiple conditions on a matcher, eg:
```ruby
  it {should contain_file('foo').with_content(/asdf/).with_content(/jkl;/)}
```


# 0.1.0

  * Initial release
