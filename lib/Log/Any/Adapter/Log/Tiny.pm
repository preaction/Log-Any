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
foreach my $method ( Log::Any->logging_methods() ) {
    my $log_tiny_method = uc($method);
    __PACKAGE__->delegate_method_to_slot( 'log', $method, $log_tiny_method );
}

# We have no detection methods
#
foreach my $method ( Log::Any->detection_methods() ) {
    *{ __PACKAGE__ . "::$method" } = sub { 1 };
}

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Log::Tiny

=head1 SYNOPSIS

    use Log::Tiny;
    my $log = Log::Tiny->new('myapp.log');
    Log::Any->set_adapter('Log::Tiny', log => $log);

=head1 DESCRIPTION

This Log::Any adapter uses L<Log::Tiny|Log::Tiny> for logging. There is a
single required parameter, I<log>, which must be a valid Log::Tiny object.

=head1 LOG LEVEL TRANSLATION

Log levels are uppercased before being passed to Log::Tiny, in deference to the
Log::Tiny standard. e.g.

    notice -> NOTICE
    warning -> WARNING

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Tiny|Log::Tiny>

=head1 AUTHOR

Jonathan Swartz

=head1 COPYRIGHT & LICENSE

Copyright (C) 2007 Jonathan Swartz, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
