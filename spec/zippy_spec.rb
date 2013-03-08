require 'spec_helper'
require 'zippy'

describe Zippy do
  context 'when instantiating defined types' do
    it 'should test existence of file with parameters' do
      instance_code = %q[nginx::site {'foo': content => 'dontcare'}]
      instance = Zippy.instantiate(instance_code)
      instance.should contain_file('/etc/nginx/sites-enabled/foo').
        with_ensure('present').
        with_mode('0440')
    end

    it 'should test resources other than files' do
      instance_code = %q[nginx::site {'foo': content => 'dontcare'}]
      instance = Zippy.instantiate(instance_code)
      instance.should contain_user('www-data')
    end

    it 'should test presence of namespaced type' do
      instance_code = %q[nginx::simple_server {'foo':}]
      instance = Zippy.instantiate(instance_code)
      instance.should contain_nginx__site('foo')
    end

    it 'should test content from a template' do
      instance_code = %q[nginx::simple_server {'foo':}]
      instance = Zippy.instantiate(instance_code)
      instance.should contain_nginx__site('foo').
        with_content(/server_name foo;/)
    end
  end

  it 'should test classes' do
    catalog = Zippy.include 'webapp'
    catalog.should contain_nginx__site('webapp')
  end

  context 'when stubbing function calls' do
    it 'should return the value given' do
      stubs = {:extlookup => {'ssh-key-barry' => 'the key of S'}}
      catalog = Zippy.include('functions::class_test', :stubs => stubs)
      catalog.should contain_ssh_authorized_key('barry').with_key('the key of S')
    end

    it 'should return the value given when instantiating a defined type' do
      stubs = {:extlookup => {'ssh-key-barry' => 'the key of S'}}
      catalog = Zippy.instantiate(%[functions::define_test{'foo': }], :stubs => stubs)
      catalog.should contain_ssh_authorized_key('barry').with_key('the key of S')
    end

    context 'when stubbing data different to that provided' do
      it 'should throw an exception' do
        stubs = {:extlookup => {'bananas' => 'potassium'}}
        expect { catalog = Zippy.include('functions::class_test',:stubs=>stubs) }.
          to raise_error Puppet::Error
      end
    end
  end

  context 'when providing recursive stubs' do
    it 'should return the value given' do
      stubs = {:extlookup =>
        { 'ssh-key-barry' => 'rsa-key-barry',
          'rsa-key-barry' => 'the key of S'}}
      Zippy.include('functions::recursive_extlookup_test', :stubs => stubs).
        should contain_ssh_authorized_key('barry').with_key('the key of S')
    end
  end

  context 'when stubbing facts' do
    context 'while instantiating defined types' do
      it 'should lookup unqualified fact from stub' do
        catalog = Zippy.instantiate(%q[facts::define_test{'test':}], :facts => {'unqualified_fact' => 'hello world'})
        catalog.should contain_notify('unqualified-fact-test').with_message('hello world')
      end

      it 'should lookup qualified fact from stub' do
        catalog = Zippy.instantiate(%q[facts::define_test{'test':}], :facts => {'qualified_fact' => 'hello world'})
        catalog.should contain_notify('qualified-fact-test').with_message('hello world')
      end
    end

    context 'while including classes' do
      it 'should lookup unqualified fact from stub' do
        catalog = Zippy.include('facts::class_test', :facts => {'unqualified_fact' => 'hello world'})
        catalog.should contain_notify('unqualified-fact-test').with_message('hello world')
      end

      it 'should lookup qualified fact from stub' do
        catalog = Zippy.include('facts::class_test', :facts => {'qualified_fact' => 'hello world'})
        catalog.should contain_notify('qualified-fact-test').with_message('hello world')
      end
    end
  end
end
