
# This file tests the import() method of the main Log::Any class. The
# tests in this file will frequently simply die if they fail.
#

use strict;
use warnings;
use Test::More tests => 1;
use Log::Any::Test;

# Test that we are allowed to call the imported Log::Any::Proxy object
# anything we want
{
    package test1;
    use Log::Any qw( $ANYTHING );
    $ANYTHING->info( 'This must not die' );
    $ANYTHING->contains_ok( qr/This must not die/, 'logged correctly' );
}

