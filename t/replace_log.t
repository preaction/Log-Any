use strict;
use warnings;
use Test::More;
use Log::Any qw($log);
use Log::Any::Adapter ();

Log::Any::Adapter->set('Test');
$log->info("for main");
$log->category_contains_ok(
    main => qr/for main/,
    'main log appeared in memory'
);

done_testing;
