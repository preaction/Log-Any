package Log::Any::Proxy::Test;
use strict;
use warnings;

# ABSTRACT: Log::Any testing proxy
# VERSION

use base qw/Log::Any::Proxy/;

my @test_methods = qw(
  msgs
  clear
  contains_ok
  category_contains_ok
  does_not_contain_ok
  category_does_not_contain_ok
  empty_ok
  contains_only_ok
);

foreach my $name (@test_methods) {
    Log::Any->make_method( $name,
        sub { my $self = shift; $self->{adapter}->$name(@_) } );
}

1;
