use strict;
use warnings;
use Test::More;
use Log::Any::Test;
use Log::Any::Adapter 'Test';

plan tests => 4;

my $log;

$log = Log::Any->get_logger( prefix => 'Foo: ' );
$log->info("test");
$log->contains_ok(qr/^Foo: test$/, 'prefix added');
$log->clear;

$log = Log::Any->get_logger( filter => sub { "@_"} );
$log->emergency("test");
$log->contains_ok(qr/^main 0 test$/, 'filter has category and numeric level');
$log->clear;

$log = Log::Any->get_logger( formatter => sub { "@_"} );
$log->tracef("test foo");
$log->contains_ok(qr/^main 8 test foo$/, 'formatter has category and numeric level');
$log->clear;

$log = Log::Any->get_logger( category => 'Foo', filter => sub { "@_"}  );
$log->info("test");
$log->contains_ok(qr/^Foo 6 test$/, 'category override');
$log->clear;
