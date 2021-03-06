require 'minitest/autorun'
require 'fizzgig'

HERE = File.expand_path(File.dirname(__FILE__))

MODULEPATH  = "#{File.join(HERE, '../spec/modules')}:#{File.join(HERE, '../spec/extra_modules')}"
MANIFESTDIR = File.join(HERE,'../spec/manifests')

class TestNginxSite < MiniTest::Unit::TestCase
  def setup
    @fizzgig = Fizzgig.new({modulepath: MODULEPATH, manifestdir: MANIFESTDIR})
    @catalog = @fizzgig.instantiate 'nginx::site','www.foo.com',{}
  end

  def test_has_sites_available_file
    assert @catalog.resource('file',
               '/etc/nginx/sites-available/www.foo.com')
  end
end
