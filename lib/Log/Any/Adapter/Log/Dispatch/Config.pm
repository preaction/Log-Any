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

=pod

=head1 NAME

Log::Any::Adapter::Log::Dispatch::Config

=head1 SYNOPSIS

    use Log::Dispatch::Config;
    Log::Dispatch::Config->configure('/path/to/log.conf');
    Log::Any->set_adapter('Log::Dispatch');

=head1 DESCRIPTION

This Log::Any adapter uses L<Log::Dispatch::Config|Log::Dispatch::Config> for
logging. Log::Dispatch::Config must be configured before calling
I<set_adapter>. There are no parameters.

Other than initialization, this class inherits its behavior from
L<Log::Any::Adapter::Log::Dispatch|Log::Any::Adapter::Log::Dispatch>.

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Dispatch::Config|Log::Dispatch::Config>

=head1 AUTHOR

Jonathan Swartz

=head1 COPYRIGHT & LICENSE

Copyright (C) 2007 Jonathan Swartz, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
