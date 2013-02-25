require 'spec_helper'
require 'zippy'

describe Zippy::Define do
  it 'should test a define' do
    define_code = <<END
define foo () {
  file {"/etc/${title}":
    ensure  => present,
    content => "bazinga",
  }
}
END
    define = Zippy::Define.new('foo',define_code)
    define.instantiate('foobar').should contain_file('/etc/foobar')
  end
end

describe Zippy do
  it 'should test a define from a module' do
    instance_code = %q[nginx::site {'foo':}]
    instance = Zippy.instantiate(instance_code)
    instance.should contain_file('/etc/nginx/sites-enabled/foo').with_ensure('present')
  end
end
