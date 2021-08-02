package Log::Any::Adaptor::Test;
our $VERSION = '1.999_000';
# ABSTRACT: Adaptor to test logging

use base 'Log::Any::Adaptor';

sub log {
    my ( $self, $level, $message, $context ) = @_;
    push @{ $self->{log} }, [ $level, $message, { %{ $context } } ];
}

1;
