#!perl
use Test::More tests => 2;
use Log::Any;
use strict;
use warnings;

eval { Log::Any->set_adapter('Blah') };
like($@, qr{Can't locate Log/Any/Adapter/Blah}, "got error for Blah");
eval { Log::Any->set_adapter('+My::Adapter::Blah') };
like($@, qr{Can't locate My/Adapter/Blah}, "got error for +My::Adapter::Blah");
