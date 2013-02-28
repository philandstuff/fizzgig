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

  it 'should test classes' do
    catalog = Zippy.include 'webapp'
    catalog.should contain_nginx__site('webapp')
  end

  context 'when stubbing function calls' do
    let(:function_stubs) do
      {:extlookup => {'mongo-host' => '127.0.1.5'}
      }
    end
    it 'should return the value given' do
      catalog = Zippy.include 'webapp::config'
      catalog.should contain_file('/etc/webapp.conf').with_content(/mongo-host=127.0.1.5/)
    end
  end

  context 'when stubbing data different to that provided' do
    let(:function_stubs) do
      {:extlookup => {'bananas' => '127.0.1.5'}
      }
    end
    it 'should throw an exception' do
      expect { catalog = Zippy.include 'webapp::config' }.
        to raise_error Puppet::Error
    end
  end
end
