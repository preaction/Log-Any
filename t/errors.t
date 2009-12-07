#!perl
use Test::Simple tests => 2;
use Log::Any;
use strict;
use warnings;

eval {
    package Foo;
    Log::Any->import(qw($foo));
};
ok( $@ =~ qr{invalid import '\$foo'}, 'invalid import $foo' );
eval {
    package Foo;
    Log::Any->import(qw(log));
};
ok( $@ =~ qr{invalid import 'log'}, 'invalid import log' );
