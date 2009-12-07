#!perl
use Test;
use Log::Any;
use strict;
use warnings;

BEGIN { plan tests => 2 }

eval {
    package Foo;
    Log::Any->import(qw($foo));
};
ok( $@ =~ qr{invalid import '\$foo'} );
eval {
    package Foo;
    Log::Any->import(qw(log));
};
ok( $@ =~ qr{invalid import 'log'} );
