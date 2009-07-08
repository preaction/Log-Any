package Log::Any::Adapter::Log::Dispatch;
use Carp qw(croak);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

sub init {
    my ($self) = @_;

    croak 'must supply dispatcher' unless defined( $self->{dispatcher} );
}

# Delegate methods to dispatcher
#
foreach my $method ( __PACKAGE__->logging_and_detection_methods() ) {
    __PACKAGE__->delegate_method_to_slot( $method, 'dispatcher' );
}

1;
