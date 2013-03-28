node 'foo.com' {
  nginx::site {'foo.com':}
}
node 'fact.com' {
  nginx::site {$::fact_site: }
}
node 'default' {
  notify{'oops, default':}
}
