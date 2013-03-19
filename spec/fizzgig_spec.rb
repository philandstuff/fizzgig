require 'spec_helper'
require 'fizzgig'

describe Fizzgig do
  describe '#include' do
    subject { Fizzgig.include(classname, :stubs => stubs, :facts => facts) }
    let(:stubs) { {} }
    let(:facts) { {} }

    describe 'webapp' do
      let(:classname) {'webapp'}

      it { should contain_nginx__site('webapp') }
    end

    describe 'functions::class_test' do
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
    end

    describe 'functions::recursive_extlookup_test' do
      let(:classname) {'functions::recursive_extlookup_test'}
      let(:stubs) {
        {:extlookup =>
          { 'ssh-key-barry' => 'rsa-key-barry',
            'rsa-key-barry' => 'the key of S'}}
      }
      it { should contain_ssh_authorized_key('barry').with_key('the key of S') }
    end

    describe 'facts::class_test' do
      let(:classname) {'facts::class_test'}
      let(:facts) {
        { 'unqualified_fact'      => 'F',
          'qualified_fact'        => 'B+',
          'template_visible_fact' => 'wibble' }}
      it { should contain_notify('unqualified-fact-test').with_message('F') }
      it { should contain_notify('qualified-fact-test').with_message('B+') }
      it { should contain_file('template-test').with_content(/instance_fact:wibble/) }
      it { should contain_file('template-test').with_content(/accessor_fact:wibble/) }
      it { should contain_file('template-test').with_content(/scope_lookup_fact:wibble/) }
    end
  end

  describe '#instantiate' do
    subject { Fizzgig.instantiate(code, :stubs => stubs, :facts => facts) }
    let(:stubs) { {} }
    let(:facts) { {} }

    describe 'params' do
      context 'when specifying one parameter' do
        let(:code) { %q[params_test {'foo': param => 'bar'}] }
        it { should contain_file('foo-param').with_source('bar') }
        it { should contain_notify('foo-default').with_message('default_val') }
      end
      context 'when specifying both paramaters' do
        let(:code) { %q[params_test {'foo': param => 'bar', param_with_default => 'baz'}] }
        it { should contain_file('foo-param').with_source('bar') }
        it { should contain_notify('foo-default').with_message('baz') }
      end
    end

    describe 'nginx::site' do
      context 'basic functionality' do
        let(:code) { %q[nginx::site {'foo': content => 'dontcare'}] }
        it { should contain_file('/etc/nginx/sites-enabled/foo').
          with_ensure('present').
          with_mode('0440')
        }
        it { should_not contain_file('/etc/nginx/sites-enabled/foo').
          with_ensure(/text not present/). # test that this doesn't get ignored
          with_ensure(/present/)
        }
        it { should contain_user('www-data') }
      end
    end

    describe 'nginx::simple_server' do
      context 'basic functionality' do
        let(:code) { %q[nginx::simple_server {'foo':}] }
        it { should contain_nginx__site('foo').
          with_content(/server_name foo;/)
        }
      end
    end

    context 'functions::define_test with function stubs' do
      let(:stubs) { {:extlookup => {'ssh-key-barry' => 'the key of S'}} }
      let(:code) { %[functions::define_test{'foo': }] }
      it { should contain_ssh_authorized_key('barry').with_key('the key of S') }
    end

    describe 'facts::define_test' do
      let(:classname) {'facts::define_test'}
      let(:code) {%q[facts::define_test{'test':}]}
      let(:facts) {
        { 'unqualified_fact' => 'no qualifications',
          'qualified_fact'   => 'cse ungraded in metalwork'}
      }
      it { should contain_notify('unqualified-fact-test').with_message('no qualifications') }
      it { should contain_notify('qualified-fact-test').with_message('cse ungraded in metalwork') }
    end
  end
end
