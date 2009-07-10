package Log::Any::Adapter::Log::Log4perl;
use Log::Log4perl;
use Carp qw(croak);
use Log::Any::Util qw(make_method);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

sub init {
    my ($self) = @_;

    $self->{logger} = Log::Log4perl->get_logger( $self->{category} );
}

# Delegate methods to logger, mapping levels down to log4perl levels where necessary
#
foreach my $method ( Log::Any->logging_and_detection_methods() ) {
    my $log4perl_method = $method;
    for ($log4perl_method) {
        s/notice/info/;
        s/warning/warn/;
        s/critical|alert|emergency/fatal/;
    }
    __PACKAGE__->delegate_method_to_slot( 'logger', $method, $log4perl_method );
}

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Log::Log4perl

=head1 SYNOPSIS

    use Log::Log4perl;
    Log::Log4perl::init('/etc/log4perl.conf');
    Log::Any->set_adapter('Log::Log4perl');

=head1 DESCRIPTION

This Log::Any adapter uses L<Log::Log4perl|Log::Log4perl> for logging. log4perl
must be initialized before calling I<set_adapter>. There are no parameters.

=head1 LOG LEVEL TRANSLATION

Log levels are translated from Log::Any to Log4perl as follows:

    notice -> info
    warning -> warn
    critical -> fatal
    alert -> fatal
    emergency -> fatal

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Log4perl|Log::Log4perl>

=head1 AUTHOR

Jonathan Swartz

=head1 COPYRIGHT & LICENSE

Copyright (C) 2007 Jonathan Swartz, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
