use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use Log::Any::Adapter::Util qw(cmp_deeply read_file);

plan tests => 15;

require Log::Any::Adapter;

{
    my $tempdir = tempdir( 'name-XXXX', TMPDIR => 1, CLEANUP => 1 );
    my $file = "$tempdir/temp.log";
    Log::Any::Adapter->set( 'File', $file, log_level => 'info' );
    my $log = Log::Any->get_logger();
    ok( ! $log->is_debug, "file won't log debugs" );
    ok( $log->is_warn, "file will log warnings" );
    $log->debug("to file");
    is( scalar( read_file($file) ), '', "debug not logged to file" );
    $log->warn("to file");
    like( scalar( read_file($file) ), qr/^\[.*\] to file\n$/, "warn logged to file" );
    {
        my $file = "$tempdir/temp2.log";
        Log::Any::Adapter->set({lexically => \my $lex}, 'File', $file);
        ok( $log->is_trace, "file will log trace lexically" );
    }
}

{
    my $buf = '';
    open my $fh, ">", \$buf;
    local *STDOUT = $fh;
    Log::Any::Adapter->set('Stdout', log_level => 'info');
    my $log = Log::Any->get_logger();
    ok( ! $log->is_debug, "stdout won't log debugs" );
    ok( $log->is_warn, "stdout will log warnings" );
    $log->debug("to stdout");
    is( $buf, '', "debug not logged to stdout" );
    $log->warn("to stdout");
    like( $buf, qr/^to stdout\n$/, "warn logged to stdout" );
    {
        Log::Any::Adapter->set({lexically => \my $lex}, 'Stdout');
        ok( $log->is_trace, "stdout will log trace lexically" );
    }
}

{
    my $buf = '';
    open my $fh, ">", \$buf;
    local *STDERR = $fh;
    Log::Any::Adapter->set('Stderr', log_level => 'info');
    my $log = Log::Any->get_logger();
    ok( ! $log->is_debug, "stderr won't log debugs" );
    ok( $log->is_warn, "stderr will log warnings" );
    $log->debug("to stderr");
    is( $buf, '', "debug not logged to stderr" );
    $log->warn("to stderr");
    like( $buf, qr/^to stderr\n$/, "warn logged to stderr" );
    {
        Log::Any::Adapter->set({lexically => \my $lex}, 'Stderr');
        ok( $log->is_trace, "stderr will log trace lexically" );
    }
}

