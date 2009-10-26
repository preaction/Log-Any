#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok('Log::Any');
}

diag("Testing Log::Any $Log::Any::VERSION, Perl $], $^X");
