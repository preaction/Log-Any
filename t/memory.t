#!perl
use Test::More tests => 21;
use Test::Deep qw(cmp_deeply);
use strict;
use warnings;

{

    package Foo;
    use Log::Any qw($log);

    sub log_debug {
        my ( $class, $text ) = @_;
        $log->debug($text) if $log->is_debug();
    }
}
{

    package Bar;
    use Log::Any qw($log);

    sub log_info {
        my ( $class, $text ) = @_;
        $log->info($text) if $log->is_info();
    }
}

my $main_log = Log::Any->get_logger();
is($main_log, Log::Any->get_logger(), "memoization - no cat");
is($main_log, Log::Any->get_logger(category => 'main'), "memoization - cat");

isa_ok( $Foo::log, 'Log::Any::Adapter::Null', 'Foo::log starts as null' );
isa_ok( $Bar::log, 'Log::Any::Adapter::Null', 'Foo::log starts as null' );
isa_ok( $main_log, 'Log::Any::Adapter::Null', 'Foo::log starts as null' );

Log::Any->set_adapter('+Log::Any::Test::Adapter::Memory');

isa_ok( $Foo::log, 'Log::Any::Test::Adapter::Memory',
    'Foo::log is now memory' );
isa_ok( $Bar::log, 'Log::Any::Test::Adapter::Memory',
    'Bar::log is now memory' );
isa_ok( $main_log, 'Log::Any::Test::Adapter::Memory',
    'main_log is now memory' );
ok($Foo::log ne $Bar::log, 'Foo::log and Bar::log are different');
is($main_log, Log::Any->get_logger(), "memoization - no cat");
is($main_log, Log::Any->get_logger(category => 'main'), "memoization - cat");

cmp_deeply( $Foo::log->{msgs}, [], 'Foo::log has empty buffer' );
cmp_deeply( $Bar::log->{msgs}, [], 'Bar::log has empty buffer' );
cmp_deeply( $main_log->{msgs}, [], 'Bar::log has empty buffer' );
ok($Foo::log->{msgs} ne $Bar::log->{msgs}, 'Foo::log and Bar::log have different buffers');

Foo->log_debug('for foo');
Bar->log_info('for bar');
$main_log->error('for main');

cmp_deeply(
    $Foo::log->{msgs},
    [ { level => 'debug', category => 'Foo', text => 'for foo' } ],
    'Foo log appeared in memory'
);
cmp_deeply(
    $Bar::log->{msgs},
    [ { level => 'info', category => 'Bar', text => 'for bar' } ],
    'Foo log appeared in memory'
);
cmp_deeply(
    $main_log->{msgs},
    [ { level => 'error', category => 'main', text => 'for main' } ],
    'main log appeared in memory'
);

Log::Any->set_adapter('Null');

isa_ok( $Foo::log, 'Log::Any::Adapter::Null', 'Foo::log is null again' );
isa_ok( $Bar::log, 'Log::Any::Adapter::Null', 'Foo::log is null again' );
isa_ok( $main_log, 'Log::Any::Adapter::Null', 'main_log is null again' );
