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
foreach my $method ( Log::Any->logging_and_detection_methods() ) {
    __PACKAGE__->delegate_method_to_slot( 'dispatcher', $method, $method );
}

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Log::Dispatch

=head1 SYNOPSIS

    use Log::Dispatch;
    my $dispatcher = Log::Dispatch->new();
    $dispatcher->add(Log::Dispatch::File->new(...));
    $dispatcher->add(Log::Dispatch::Screen->new(...));
    Log::Any->set_adapter('Log::Dispatch', dispatcher => $dispatcher);

=head1 DESCRIPTION

This Log::Any adapter uses L<Log::Dispatch|Log::Dispatch> for logging. There is
a single required parameter, I<dispatcher>, which must be a valid Log::Dispatch
object.

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Dispatch|Log::Dispatch>

=head1 AUTHOR

Jonathan Swartz

=head1 COPYRIGHT & LICENSE

Copyright (C) 2007 Jonathan Swartz, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
