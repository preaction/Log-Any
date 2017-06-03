#! /usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;

use Log::Any::Adapter;
use Log::Any '$log';

use File::Basename;
use FindBin;
use lib $FindBin::RealBin;
use TestAdapters;

$log->context->{progname} = basename($0);
$log->context->{pid}      = 42;

sub process_dir {
    my ($dir) = @_;
    local $log->context->{directory} = $dir;
    for ( 1 .. 3 ) {
        local $log->context->{pass} = $_;
        $log->info('Performing work');
    }
}

Log::Any::Adapter->set('+TestAdapters::Normal');
process_dir('/foo');

Log::Any::Adapter->set('+TestAdapters::Structured');
process_dir('/bar');

my @expected_text_log = map {
    qq(Performing work {directory => "/foo",pass => $_,pid => 42,progname => "context.t"})
} ( 1 .. 3 );

my @expected_structured_log = map {
    {   category => 'main',
        data     => [
            {   directory => '/bar',
                pass      => $_,
                pid       => 42,
                progname  => 'context.t'
            }
        ],
        level    => 'info',
        messages => ['Performing work']
    }

} ( 1 .. 3 );

is_deeply( \@TestAdapters::TEXT_LOG, \@expected_text_log,
    'text log is correct' );
is_deeply( \@TestAdapters::STRUCTURED_LOG,
    \@expected_structured_log, 'structured log is correct' );
