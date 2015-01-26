use strict;
use warnings;
use Test::More;

plan tests => 4;

our $BUF;

package MyApp::Log::Adapter;
use base qw(Log::Any::Adapter::Base);
foreach my $method ( Log::Any->logging_methods() ) {
    no strict 'refs';
    *$method = sub { $main::BUF .= "$_[1]\n"};
}
foreach my $method ( Log::Any->detection_methods() ) {
    no strict 'refs';
    *$method = sub { 1 };
}

package main;
use Log::Any::Adapter;
eval { Log::Any::Adapter->set('+MyApp::Log::Adapter') };
is( $@, "", "setting inner package as adapter is OK");

my $log = Log::Any->get_logger;

$log->critical("DIE DIE DIE");
is( $BUF, "DIE DIE DIE\n", "logged a message via inner adapter" );

# Test that we can change methods at runtime and it still works,
# and test that aliases can be overridden separate from the main method.
{
    no warnings 'once';
    no warnings 'redefine';
    local *MyApp::Log::Adapter::fatal= sub { 1 };
    local *MyApp::Log::Adapter::critical= sub { 2 };
    is( $log->critical('foo'), 2, 'dispatching dynamically by name' );
    is( $log->fatal('foo'),    1, 'differentiate fatal from critical' );
}