package Log::Any::Adapter::Null;
use Log::Any::Util qw(make_alias);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

# All methods are no-ops
#
foreach my $method ( Log::Any->logging_and_detection_methods() ) {
    make_alias($method, sub {});
}

1;
