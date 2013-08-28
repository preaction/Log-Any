package Log::Any::Adapter::FileScreenBase;
use Log::Any::Adapter::Util qw(make_method);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

sub make_logging_methods {
    my ( $class, $code ) = @_;
    foreach my $method ( Log::Any->logging_methods() ) {
        make_method( $method, $code, $class );
    }
}

foreach my $method ( Log::Any->detection_methods() ) {
    make_method( $method, sub { 1 } );
}

1;
