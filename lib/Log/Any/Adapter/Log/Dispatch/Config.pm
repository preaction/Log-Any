package Log::Any::Adapter::Log::Dispatch::Config;
use Log::Dispatch::Config;
use strict;
use warnings;
use base qw(Log::Any::Adapter::Log::Dispatch);

sub init {
    my ($self) = @_;

    $self->{dispatcher} ||= Log::Dispatch::Config->instance;
}

1;
