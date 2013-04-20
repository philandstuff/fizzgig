require 'minitest/autorun'
require 'fizzgig'

HERE = File.expand_path(File.dirname(__FILE__))

RSpec.configure do |c|
  c.modulepath  = "#{File.join(HERE, '../spec/modules')}:#{File.join(HERE, '../spec/extra_modules')}"
  c.manifestdir = File.join(HERE,'../spec/manifests')
end

class TestNginxSite < MiniTest::Unit::TestCase
  def setup
    @catalog = Fizzgig.instantiate 'nginx::site','www.foo.com'
  end

  def test_has_sites_available_file
    assert @catalog.resource('file',
               '/etc/nginx/sites-available/www.foo.com')
  end
end
