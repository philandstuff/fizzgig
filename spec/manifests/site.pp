node 'foo.com' {
  nginx::site {'foo.com':}
}
node 'default' {
  notify{'oops, default':}
}
