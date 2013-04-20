require 'spec_helper'
require 'fizzgig'
require 'rspec-puppet'

describe 'nginx::site' do
  include RSpec::Puppet::ManifestMatchers
  let(:fizzgig) { Fizzgig.new({modulepath:MODULEPATH,manifestdir:MANIFESTDIR}) }
  subject { fizzgig.instantiate 'nginx::site','www.foo.com',{} }
  it { should contain_file('/etc/nginx/sites-available/www.foo.com').
         with_content(/server_name\s+www.foo.com;/) }
  it { should contain_file('/etc/nginx/sites-enabled/www.foo.com').
         with_ensure('link').
         with_target('/etc/nginx/sites-available/www.foo.com') }
end
