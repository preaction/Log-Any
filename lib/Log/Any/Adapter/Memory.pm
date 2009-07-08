package Log::Any::Adapter::Memory;
use Log::Any::Util qw(make_alias);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

foreach my $method ( Log::Any->logging_methods() ) {
    make_alias( $method,
        sub { my ( $self, $msg ) = @_; push( @{ $self->{msgs} }, $msg ) } );
}

foreach my $method ( Log::Any->detection_methods() ) {
    make_alias( $method, sub { my ( $self, $msg ) = @_; return 1 } );
}

1;
