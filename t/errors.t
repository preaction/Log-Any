#!perl
use Test::More tests => 2;
use Log::Any;
use strict;
use warnings;

eval {
    package Foo;
    Log::Any->import(qw($foo));
};
like( $@, qr{invalid import '\$foo'}, 'invalid import $foo' );
eval {
    package Foo;
    Log::Any->import(qw(log));
};
like( $@, qr{invalid import 'log'}, 'invalid import log' );
