package Log::Any::Test::InternalOnly;
use Test::More;
use strict;
use warnings;

sub import {
    unless ( $ENV{LOG_ANY_INTERNAL_TESTS} ) {
        plan skip_all => "internal test only";
    }
}

1;
