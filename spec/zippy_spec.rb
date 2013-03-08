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
    instance.should contain_notify('nginx message')
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
    it 'should return the value given' do
      stubs = {:extlookup => {'mongo-host' => '127.0.1.5'}}
      catalog = Zippy.include('webapp::config', :stubs => stubs)
      catalog.should contain_file('/etc/webapp.conf').with_content(/mongo-host=127.0.1.5/)
    end

    it 'should return the value given when instantiating a defined type' do
      stubs = {:extlookup => {'bar' => '99 bottles of beer'}}
      catalog = Zippy.instantiate(%[nginx::site{'foo': message => extlookup('bar')}], :stubs => stubs)
      catalog.should contain_notify('nginx message').with_message('99 bottles of beer')
    end
  end

  context 'when stubbing data different to that provided' do
    it 'should throw an exception' do
      stubs = {:extlookup => {'bananas' => '127.0.1.5'}}
      expect { catalog = Zippy.include('webapp::config',:stubs=>stubs) }.
        to raise_error Puppet::Error
    end
  end

  context 'when providing recursive stubs' do
    it 'should return the value given' do
      stubs = {:extlookup =>
        { 'foo' => 'bar',
          'bar' => 'baz'}}
      Zippy.include('webapp::config2', :stubs => stubs).
        should contain_file('/etc/webapp.conf').with_content(/mongo-host=baz/)
    end
  end

  context 'when stubbing facts' do
    context 'while instantiating defined types' do
      it 'should lookup unqualified fact from stub' do
        catalog = Zippy.instantiate(%q[nginx::site{'foo': message => $fact}], :facts => {'fact' => 'hello world'})
        catalog.should contain_notify('nginx message').with_message('hello world')
      end
    end
  end
end
