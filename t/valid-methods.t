#!perl
use Test::More;
use Log::Any qw($log);
use strict;
use warnings;

my @logs;
push( @logs, $log );
push( @logs, Log::Any->get_logger() );
push( @logs, Log::Any->get_logger( category => 'Foo' ) );

my $logging_method_count   = scalar( Log::Any->logging_methods() );
my $detection_method_count = scalar( Log::Any->logging_methods() );
plan tests => ( $logging_method_count * 2 + $detection_method_count + 1 ) * 3;

foreach my $log (@logs) {
    foreach my $method ( Log::Any->detection_methods() ) {
        ok( !$log->$method, "!$method" );
    }
    foreach my $method ( Log::Any->logging_methods() ) {
        ok( $log->$method("") || 1, "$method runs" );
        my $methodf = $method . "f";
        ok( $log->$methodf("") || 1, "$method runs" );
    }
    eval { $log->bad_method() };
    like( $@, qr{Can\'t locate object method "bad_method"}, "bad method" );
}
