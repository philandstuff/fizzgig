require 'spec_helper'
require 'zippy'

describe Zippy do
  it 'should test a define from a module' do
    instance_code = %q[nginx::site {'foo':}]
    instance = Zippy.instantiate(instance_code)
    instance.should contain_file('/etc/nginx/sites-enabled/foo').
      with_ensure('present').
      with_mode('0440')
  end

  it 'should test resources other than files' do
    instance_code = %q[nginx::site {'foo':}]
    instance = Zippy.instantiate(instance_code)
    instance.should contain_notify('different resource type')
  end

  it 'should test content from a template' do
    instance_code = %q[nginx::site {'foo':}]
    instance = Zippy.instantiate(instance_code)
    instance.should contain_file('/etc/nginx/sites-enabled/foo').
      with_content(/server_name foo;/)
  end

  it 'should test presence of namespaced type' do
    instance_code = %q[nginx::site {'foo':}]
    instance = Zippy.instantiate(instance_code)
    instance.should contain_nginx__wibble('foo')
  end
end
