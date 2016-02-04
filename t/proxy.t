use strict;
use warnings;
use Test::More;
use Log::Any::Test;
use Log::Any::Adapter 'Test';

plan tests => 7;

my $log;

$log = Log::Any->get_logger( prefix => 'Foo: ' );
$log->info("test");
$log->contains_ok(qr/^Foo: test$/, 'prefix added');
$log->clear;

$log = Log::Any->get_logger;
$log->info(qw/one two three four/);
$log->contains_ok(qr/^one two three four$/, 'arguments concatenated');
$log->clear;

$log = Log::Any->get_logger;
$log->infof(sub { "ran sub" } );
$log->contains_ok(qr/^ran sub$/, 'default formatter expands coderefs');
$log->clear;

$log = Log::Any->get_logger;
$log->infof("got %s %s", "coderef", sub { "expanded" } );
$log->contains_ok(qr/DUMMY/, 'default formatter does not expand coderefs as sprintf args');
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
