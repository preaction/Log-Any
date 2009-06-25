#!perl
use Test::Most tests => 100;
use Log::Any;
use strict;
use warnings;

my @loggers = map { Log::Any::Test::Logger->new() } ( 0 .. 2 );
my $null_logger = Log::Any->null_logger();

sub test_null_logger {
    is( Log::Any->get_logger(),
        $null_logger "returns null logger for default category" );
    is( Log::Any->get_logger( category => 'Blah' ),
        $null_logger, "returns null logger for category 'Blah'" );
    Log::Any->set_logger( $loggers[0] );
    isnt( Log::Any->get_logger( category => 'Blah' ),
        $null_logger, "not returning null logger after set of object" );
    Log::Any->set_logger(undef);
    is( Log::Any->get_logger( category => 'Blah' ),
        $null_logger, "returning null logger after set of undef" );

    foreach my $level (qw(debug info warn error fatal)) {
        my $is_level = "is_$level";
        lives_ok { $null_logger->$level() } "null logger can '$level'";
        ok( !$null_logger->$is_level(),
            "null logger returns false for '$is_level'" );
    }
}

sub test_set_object {
    Log::Any->set_logger( $loggers[0] );
    is( Log::Any->get_logger(), $loggers[0],
        "returns log object for default category" );
    is( Log::Any->get_logger( category => 'Blah' ),
        $loggers[0], "returns log object for any category" );
}

sub test_set_code {

    # Log::Any->set_logger( { 'Foo' => $loggers[0], 'Bar' => $loggers[1] } );
    Log::Any->set_logger(
        sub {
            my $category = shift;
            return
                $category eq 'Foo' ? $loggers[0]
              : $category eq 'Bar' ? $loggers[1]
              :                      undef;
        }
    );
    is( Log::Any->get_logger( category => 'Foo' ),
        $loggers[0], "got logger 0 for Foo" );
    is( Log::Any->get_logger( category => 'Bar' ),
        $loggers[1], "got logger 1 for Bar" );
    is( Log::Any->get_logger( category => 'Baz' ),
        $null_logger, "got null logger for Baz" );

    foreach my $pkg (qw(Foo Bar Baz)) {
        eval "package $pkg; use Log::Any qw(\$log)";
        is(
            eval("$pkg::log"),
            Log::Any->get_logger( category => $pkg ),
            "logger in package $pkg matches get_logger"
        );
    }
}

main();
