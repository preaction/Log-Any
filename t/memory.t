#!perl
use Test::More tests => 10;
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

isa_ok( $Foo::log, 'Log::Any::Adapter::Null', 'Foo::log starts as null' );
isa_ok( $Bar::log, 'Log::Any::Adapter::Null', 'Foo::log starts as null' );

Log::Any->set_adapter('+Log::Any::Test::Adapter::Memory');

isa_ok( $Foo::log, 'Log::Any::Test::Adapter::Memory',
    'Foo::log is now memory' );
isa_ok( $Bar::log, 'Log::Any::Test::Adapter::Memory',
    'Bar::log is now memory' );
ok($Foo::log ne $Bar::log, 'Foo::log and Bar::log are different');

cmp_deeply( $Foo::log->{msgs}, [], 'Foo::log has empty buffer' );
cmp_deeply( $Bar::log->{msgs}, [], 'Bar::log has empty buffer' );
ok($Foo::log->{msgs} ne $Bar::log->{msgs}, 'Foo::log and Bar::log have different buffers');

Foo->log_debug('for foo');
Bar->log_info('for bar');

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
