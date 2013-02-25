require 'spec_helper'
require 'zippy'

describe Zippy do
  it 'should test a define from a module' do
    instance_code = %q[nginx::site {'foo':}]
    instance = Zippy.instantiate(instance_code)
    instance.should contain_file('/etc/nginx/sites-enabled/foo').
      with_ensure('present').
      with_mode('0440')
    instance.should contain_notify('different resource type')
  end
end
