# Fizzgig

Fizzgig is a library to help write fast unit tests.

```ruby
# See spec/example_spec.rb
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
```

## Basic Functionality

Fizzgig is based around two functions: `instantiate` and `include`,
which will instantiate a defined type and include a class
respectively:

```ruby
catalog = Fizzgig.instantiate 'nginx::site', 'foo.com', { max_age => 300 }
```

```ruby
catalog = Fizzgig.include 'nginx'
```

Each of these functions returns a Puppet::Resource::Catalog
object. This means you can use the matchers from rspec-puppet in
RSpec::Puppet::ManifestMatchers to make assertions against the
contents of this catalog:

```ruby
catalog.should contain_file('/etc/nginx.conf').with_content(/ssl/)
```

## Stubbing facts

Facts can be stubbed by passing a hash of fact values to instantiate
or include:

```ruby
Fizzgig.include('nginx',:facts => {'lsbdistcodename' => 'precise'})
```

## Stubbing functions

Custom functions can also be stubbed. This is very handy for stubbing
out extdata or hieradata in tests:

```ruby
Fizzgig.include('nginx',:stubs => {:extlookup => {'site_root' => 'www.foo.com'}})
  .should contain_file('/etc/nginx/sites-enabled/www.foo.com')
```

## Rationale

Fizzgig is designed to be fast, and to test individual units of code,
as good unit tests do. However, existing puppet testing libraries such
as [rspec-puppet][] will compute a complete catalog, expanding out all
classes and defined types until it reaches the individual base puppet
types. This means that it can spend time computing resources which are
wholly unrelated to the test you're writing.

Fizzgig, by contrast, treats defined types as black box abstractions:
it only adds the defined types you declare within the class or define
under test to the catalog. Types which are pulled in transitively by
other types will not be added to the catalog.

To achieve its isolation, fizzgig does not transitively evaluate
defined types. Suppose I have these puppet defines:

```puppet
define nginx::ssl_site () {
  nginx::site {$title:
  }
  nginx::ssl_cert {$title:
  }
}

define nginx::site () {
  file {"/etc/nginx/sites-enabled/$title":
    # ...
  }
}
```

And I write this test:

```ruby
catalog = Fizzgig.instantiate 'nginx::ssl_site','foo'
catalog.should contain_nginx__site('foo') # ok, will pass
catalog.should contain_file('/etc/nginx/sites-enabled/foo') # ERROR, will fail
```

Because the file resource is not directly referenced by
`nginx::ssl_site` but only transitively by `nginx::site`, Fizzgig will
not add it to the catalog. This means that Fizzgig will only test the
direct effects of the type under test, not of its collaborators.


WARNING: Fizzgig makes use of non-public methods in the puppet
codebase to enable it to perform this isolation. This means that even
a patch release of puppet may, in principle, cause fizzgig to
break. Fizzgig is not currently supported in any way by
puppetlabs. Use at your own risk.

## Installation

Add the following to your Gemfile:

```ruby
gem "fizzgig"
```

Or just run:

```
gem install fizzgig
```

## Licence

MIT. See LICENSE for details.

[rspec-puppet]: https://github.com/rodjek/rspec-puppet
