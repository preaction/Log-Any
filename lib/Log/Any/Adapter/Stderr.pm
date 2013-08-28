package Log::Any::Adapter::Stderr;
use strict;
use warnings;
use base qw(Log::Any::Adapter::FileScreenBase);

__PACKAGE__->make_logging_methods(
    sub {
        my ( $self, $text ) = @_;
        print STDERR "$text\n";
    }
);

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Stderr - Simple adapter for logging to STDERR

=head1 SYNOPSIS

    use Log::Any::Adapter ('Stderr');

    # or

    use Log::Any::Adapter;
    ...
    Log::Any::Adapter->set('Stderr');

=head1 DESCRIPTION

This simple built-in L<Log::Any|Log::Any> adapter logs each message to STDERR
with a newline appended.  Category and log level are ignored.

