#!/usr/bin/perl
use Test::More;
use Log::Any::Adapter qw(Stdout);
use strict;
use warnings;

{
    open my $fh, ">", \my $buf;
    local *STDOUT = $fh;
    my $log = Log::Any->get_logger();
    $log->debug("to stdout");
    like( $buf, qr/^to stdout\n$/, "stdout" );
}

done_testing;
