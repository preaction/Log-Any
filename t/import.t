#!/usr/bin/perl
use Capture::Tiny qw(capture_stdout);
use Test::More;
use Log::Any::Adapter qw(Stdout);
use strict;
use warnings;

{
    my $log = Log::Any->get_logger();
    like( capture_stdout( sub { $log->debug("to stdout") } ),
        qr/^to stdout\n$/, "stdout" );
}

done_testing;
