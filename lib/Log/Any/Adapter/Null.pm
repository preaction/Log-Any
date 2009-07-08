package Log::Any::Adapter::Null;
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

# All methods are no-ops
#
foreach my $method ( Log::Any->logging_and_detection_methods() ) {
    *{ __PACKAGE__ . "::$method" } = sub { };
}

1;
