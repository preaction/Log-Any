package Log::Any::Test::Adapter::Memory;
use Log::Any::Util qw(make_method);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

sub init {
    my ($self) = @_;

    $self->{msgs} = [];
}

foreach my $method ( Log::Any->logging_methods() ) {
    make_method(
        $method,
        sub {
            my ( $self, $text ) = @_;
            push(
                @{ $self->{msgs} },
                {
                    level    => $method,
                    category => $self->{category},
                    text     => $text
                }
            );
        }
    );
}

foreach my $method ( Log::Any->detection_methods() ) {
    make_method( $method, sub { my ( $self, $msg ) = @_; return 1 } );
}

1;
