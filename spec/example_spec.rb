require 'spec_helper'
require 'fizzgig'

describe 'nginx::site' do
  subject { Fizzgig.new.instantiate 'nginx::site','www.foo.com',{} }
  it { should contain_file('/etc/nginx/sites-available/www.foo.com').
         with_content(/server_name\s+www.foo.com;/) }
  it { should contain_file('/etc/nginx/sites-enabled/www.foo.com').
         with_ensure('link').
         with_target('/etc/nginx/sites-available/www.foo.com') }
end
