#!perl
use Test::Simple tests => 3;
use Log::Any::Test;
use Log::Any qw($log);
use strict;
use warnings;

$log->error("this is an error") if $log->is_error;
$log->debug("this is a debug")  if $log->is_debug;
$log->contains_ok( qr/this is an error/, 'got error' );
$log->contains_ok( qr/this is a debug/,  'got debug' );
$log->empty_ok();

