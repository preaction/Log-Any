#! /usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Log::Any '$log';
use Log::Any::Adapter 'Test';

use URI;

my $uri = URI->new('http://slashdot.org/');

$log->infof( 'Fetching %s', $uri );

is_deeply(
    Log::Any::Adapter::Test->msgs->[0]->{message},
    'Fetching http://slashdot.org/',
    'URI was correctly stringified'
);

done_testing;

