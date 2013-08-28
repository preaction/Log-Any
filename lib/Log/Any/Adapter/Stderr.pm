use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Stderr;

# ABSTRACT: Simple adapter for logging to STDERR
# VERSION

use base qw/Log::Any::Adapter::Base/;

foreach my $method ( Log::Any->logging_methods() ) {
    no strict 'refs';
    *{$method} = sub {
        my ( $self, $text ) = @_;
        print STDERR "$text\n";
      }
}

foreach my $method ( Log::Any->detection_methods() ) {
    no strict 'refs';
    *{$method} = sub { 1 };
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

=head1 DESCRIPTION

This simple built-in L<Log::Any|Log::Any> adapter logs each message to STDERR
with a newline appended. Category and log level are ignored.

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Any::Adapter|Log::Any::Adapter>

