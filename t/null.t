#!perl
use Test::More;
use Log::Any qw($log);
use strict;
use warnings;

plan tests =>
  scalar( Log::Any->logging_and_detection_methods() );
my $num = Log::Any->logging_and_detection_methods();
foreach my $method ( Log::Any->detection_methods() ) {
    ok( !$log->$method, "!$method" );
}
foreach my $method ( Log::Any->logging_methods() ) {
    ok( $log->$method || 1, "$method runs" );
}
