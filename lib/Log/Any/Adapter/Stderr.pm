use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Stderr;

# ABSTRACT: Simple adapter for logging to STDERR
our $VERSION = '1.032'; # TRIAL

use Log::Any::Adapter::Util ();

use base qw/Log::Any::Adapter::Base/;

my $trace_level = Log::Any::Adapter::Util::numeric_level('trace');

sub init {
    my ($self) = @_;
    if ( exists $self->{log_level} ) {
        $self->{log_level} =
          Log::Any::Adapter::Util::numeric_level( $self->{log_level} )
          unless $self->{log_level} =~ /^\d+$/;
    }
    else {
        $self->{log_level} = $trace_level;
    }
}

foreach my $method ( Log::Any::Adapter::Util::logging_methods() ) {
    no strict 'refs';
    my $method_level = Log::Any::Adapter::Util::numeric_level($method);
    *{$method} = sub {
        my ( $self, $text ) = @_;
        return if $method_level > $self->{log_level};
        print STDERR "$text\n";
    };
}

foreach my $method ( Log::Any::Adapter::Util::detection_methods() ) {
    no strict 'refs';
    my $base = substr( $method, 3 );
    my $method_level = Log::Any::Adapter::Util::numeric_level($base);
    *{$method} = sub {
        return !!( $method_level <= $_[0]->{log_level} );
    };
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Log::Any::Adapter ('Stderr');

    # or

    use Log::Any::Adapter;
    ...
    Log::Any::Adapter->set('Stderr');

    # with minimum level 'warn'

    use Log::Any::Adapter ('Stderr', log_level => 'warn' );

=head1 DESCRIPTION

This simple built-in L<Log::Any|Log::Any> adapter logs each message to STDERR
with a newline appended. Category is ignored.

The C<log_level> attribute may be set to define a minimum level to log.

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Any::Adapter|Log::Any::Adapter>

