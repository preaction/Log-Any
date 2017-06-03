use strict;
use warnings;
use Test::More tests => 1;

BEGIN { $ENV{LOG_ANY_DEFAULT_ADAPTER} = 'Test'; }

use Log::Any '$log', proxy_class => 'Test';

$log->err("this is an error");
$log->contains_ok( qr/this is an error/, 'got error' );
