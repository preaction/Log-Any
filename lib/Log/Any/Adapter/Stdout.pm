package Log::Any::Adapter::Stdout;
use strict;
use warnings;
use base qw(Log::Any::Adapter::FileScreenBase);

__PACKAGE__->make_logging_methods(
    sub {
        my ( $self, $text ) = @_;
        print STDOUT "$text\n";
    }
);

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Stdout - Simple adapter for logging to STDOUT

=head1 SYNOPSIS

    use Log::Any::Adapter ('Stdout');

    # or

    use Log::Any::Adapter;
    ...
    Log::Any::Adapter->set('Stdout');

=head1 DESCRIPTION

This simple built-in L<Log::Any|Log::Any> adapter logs each message to STDOUT
with a newline appended. Category and log level are ignored.

