use 5.008001;
use strict;
use warnings;

package Log::Any::Proxy::Test;

our $VERSION = '1.707';

use Log::Any::Proxy;
our @ISA = qw/Log::Any::Proxy/;

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
    no strict 'refs';
    *{$name} = sub {
        my $self = shift;
        $self->{adapter}->$name(@_);
    };
}

1;
