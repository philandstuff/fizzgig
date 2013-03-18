require 'spec_helper'
require 'fizzgig'

describe Fizzgig do
  describe '#include' do
    subject { Fizzgig.include(classname, :stubs => stubs) }
    let(:stubs) { {} }

    context 'with class webapp' do
      let(:classname) {'webapp'}

      it { should contain_nginx__site('webapp') }
    end

    context 'with class functions::class_test' do
      let(:classname) {'functions::class_test'}
      context 'with extlookup stubbed out' do
        let(:stubs) { {:extlookup => {'ssh-key-barry' => 'the key of S'}} }
        it { should contain_ssh_authorized_key('barry').with_key('the key of S') }
      end

      context 'with extlookup stubbed with wrong key' do
        let(:stubs) { {:extlookup => {'bananas' => 'potassium'}} }
        it 'should throw an exception' do
          expect { subject }.to raise_error Puppet::Error
        end
      end

      it 'should return the value given when instantiating a defined type' do
        stubs = {:extlookup => {'ssh-key-barry' => 'the key of S'}}
        catalog = Fizzgig.instantiate(%[functions::define_test{'foo': }], :stubs => stubs)
        catalog.should contain_ssh_authorized_key('barry').with_key('the key of S')
      end
    end
  end

  context 'when instantiating defined types' do
    it 'should test existence of file with parameters' do
      instance_code = %q[nginx::site {'foo': content => 'dontcare'}]
      instance = Fizzgig.instantiate(instance_code)
      instance.should contain_file('/etc/nginx/sites-enabled/foo').
        with_ensure('present').
        with_mode('0440')
    end

    it 'should test resources other than files' do
      instance_code = %q[nginx::site {'foo': content => 'dontcare'}]
      instance = Fizzgig.instantiate(instance_code)
      instance.should contain_user('www-data')
    end

    it 'should test presence of namespaced type' do
      instance_code = %q[nginx::simple_server {'foo':}]
      instance = Fizzgig.instantiate(instance_code)
      instance.should contain_nginx__site('foo')
    end

    it 'should test content from a template' do
      instance_code = %q[nginx::simple_server {'foo':}]
      instance = Fizzgig.instantiate(instance_code)
      instance.should contain_nginx__site('foo').
        with_content(/server_name foo;/)
    end
  end

  context 'when providing recursive stubs' do
    it 'should return the value given' do
      stubs = {:extlookup =>
        { 'ssh-key-barry' => 'rsa-key-barry',
          'rsa-key-barry' => 'the key of S'}}
      Fizzgig.include('functions::recursive_extlookup_test', :stubs => stubs).
        should contain_ssh_authorized_key('barry').with_key('the key of S')
    end
  end

  context 'when stubbing facts' do
    context 'while instantiating defined types' do
      it 'should lookup unqualified fact from stub' do
        catalog = Fizzgig.instantiate(%q[facts::define_test{'test':}], :facts => {'unqualified_fact' => 'hello world'})
        catalog.should contain_notify('unqualified-fact-test').with_message('hello world')
      end

      it 'should lookup qualified fact from stub' do
        catalog = Fizzgig.instantiate(%q[facts::define_test{'test':}], :facts => {'qualified_fact' => 'hello world'})
        catalog.should contain_notify('qualified-fact-test').with_message('hello world')
      end
    end

    context 'while including classes' do
      it 'should lookup unqualified fact from stub' do
        catalog = Fizzgig.include('facts::class_test', :facts => {'unqualified_fact' => 'hello world'})
        catalog.should contain_notify('unqualified-fact-test').with_message('hello world')
      end

      it 'should lookup qualified fact from stub' do
        catalog = Fizzgig.include('facts::class_test', :facts => {'qualified_fact' => 'hello world'})
        catalog.should contain_notify('qualified-fact-test').with_message('hello world')
      end

      it 'should lookup fact by instance variable from within template' do
        catalog = Fizzgig.include('facts::template_test', :facts => {'template_visible_fact' => 'hello world'})
        catalog.should contain_file('template-test').with_content(/instance_fact:hello world/)
      end

      it 'should lookup fact by accessor method from within template' do
        catalog = Fizzgig.include('facts::template_test', :facts => {'template_visible_fact' => 'hello world'})
        catalog.should contain_file('template-test').with_content(/accessor_fact:hello world/)
      end

      it 'should lookup fact by scope.lookupvar from within template' do
        catalog = Fizzgig.include('facts::template_test', :facts => {'template_visible_fact' => 'hello world'})
        catalog.should contain_file('template-test').with_content(/scope_lookup_fact:hello world/)
      end
    end
  end
end
