#!perl
use Test::Simple tests => 3;
use Log::Any::Test;
use Log::Any qw($log);
use strict;
use warnings;

$log->err("this is an error") if $log->is_error;
$log->debugf( "this is a %s with a defined (%s) value and an %s value",
    "debug", [ 1, 2 ], undef )
  if $log->is_debug;
$log->contains_ok( qr/this is an error/, 'got error' );
$log->contains_ok(
    qr/this is a debug with a defined \(\[1,2\]\) value and an <undef> value/,
    'got debug' );
$log->empty_ok();
