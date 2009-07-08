package Log::Any::Adapter::Log::Tiny;
use Carp qw(croak);
use Log::Tiny;
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

sub init {
    my ($self) = @_;

    croak 'must supply Log::Tiny log'
      unless defined( $self->{log} )
          && UNIVERSAL::isa( $self->{log}, 'Log::Tiny' );
}

# Delegate logging methods to $log
#
foreach my $method ( __PACKAGE__->logging_methods() ) {
    my $log_tiny_method = uc($method);
    __PACKAGE__->delegate_method_to_slot( 'log', $method, $log_tiny_method );
}

# We have no detection methods
#
foreach my $method ( __PACKAGE__->detection_methods() ) {
    *{ __PACKAGE__ . "::$method" } = sub { 1 };
}

__PACKAGE__->no_detection_methods();

1;
