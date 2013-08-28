#!/usr/bin/perl
use Test::More;
use File::Temp qw(tempdir);
use Log::Any::Adapter::Util qw(cmp_deeply read_file);
use Capture::Tiny qw(capture_stdout capture_stderr);
use strict;
use warnings;

require Log::Any::Adapter;

{
    my $tempdir = tempdir( 'name-XXXX', TMPDIR => 1, CLEANUP => 1 );
    my $file = "$tempdir/temp.log";
    Log::Any::Adapter->set( 'File', $file );
    my $log = Log::Any->get_logger();
    $log->debug("to file");
    like( scalar( read_file($file) ), qr/^\[.*\] to file\n$/, "file" );
}

{
    Log::Any::Adapter->set('Stdout');
    my $log = Log::Any->get_logger();
    like( capture_stdout( sub { $log->debug("to stdout") } ),
        qr/^to stdout\n$/, "stdout" );
}

{
    Log::Any::Adapter->set('Stderr');
    my $log = Log::Any->get_logger();
    like( capture_stderr( sub { $log->debug("to stderr") } ),
        qr/^to stderr\n$/, "stderr" );
}

done_testing;
