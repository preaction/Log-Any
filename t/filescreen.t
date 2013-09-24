use strict;
use warnings;
use Test::More tests => 3;;
use File::Temp qw(tempdir);
use Log::Any::Adapter::Util qw(cmp_deeply read_file);

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
    open my $fh, ">", \my $buf;
    local *STDOUT = $fh;
    Log::Any::Adapter->set('Stdout');
    my $log = Log::Any->get_logger();
    $log->debug("to stdout");
    like( $buf, qr/^to stdout\n$/, "stdout" );
}

{
    open my $fh, ">", \my $buf;
    local *STDERR = $fh;
    Log::Any::Adapter->set('Stderr');
    my $log = Log::Any->get_logger();
    $log->debug("to stderr");
    like( $buf, qr/^to stderr\n$/, "stderr" );
}

