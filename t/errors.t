#!perl
use Test::More tests => 5;
use Log::Any;
use strict;
use warnings;

eval { Log::Any->set_adapter('Blah') };
like($@, qr{Can't locate Log/Any/Adapter/Blah}, "adapter = Blah");
eval { Log::Any->set_adapter('+My::Adapter::Blah') };
like($@, qr{Can't locate My/Adapter/Blah}, "adapter = +My::Adapter::Blah");
eval { Log::Any->set_adapter('') };
like($@, qr{adapter class required}, "adapter = ''");
eval
{ package Foo;
  Log::Any->import(qw($foo));
};
like($@, qr{invalid import '\$foo'}, 'invalid import $foo');
eval
{ package Foo;
  Log::Any->import(qw(log));
};
like($@, qr{invalid import 'log'}, 'invalid import log');
