package Log::Any::Adapter::Syslog;
use strict;
use warnings;

# ABSTRACT: Send Log::Any logs to syslog
# VERSION

use Log::Any::Adapter::Util qw{make_method};
use base qw{Log::Any::Adapter::Base};

use Unix::Syslog qw{:macros :subs};
use File::Basename ();
use Carp qw{cluck};

my $log_params;

# When initialized we connect to syslog.
sub init {
    my ($self) = @_;

    $self->{name} ||= File::Basename::basename($0);
    $self->{name} ||= 'perl';

    $self->{options}  ||= LOG_PID;
    $self->{facility} ||= LOG_LOCAL7;

    # We want to avoid opening the syslog multiple times, but also catch the
    # unsupported case where the parameters have changed.
    if (not defined $log_params) {

        # First time in, note the parameters we used, and open the log>
        $log_params = $self->_log_params;
        openlog($self->{name}, $self->{options}, $self->{facility});
    }
    else {

        # After that, warn if the check the parameters have changed.
        if ($log_params ne $self->_log_params) {
            cluck('Attempting to reinitialize Log::Any::Adapter::Syslog with new parameters');
        }
    }

    return $self;
}

sub _log_params {
    my ($self) = @_;
    return sprintf('%d,%d,%s',
        $self->{options}, $self->{facility}, $self->{name});
}

# Create logging methods: debug, info, etc.
foreach my $method (Log::Any->logging_methods()) {
    my $priority = {
        trace     => LOG_DEBUG,
        debug     => LOG_DEBUG,
        info      => LOG_INFO,
        inform    => LOG_INFO,
        notice    => LOG_NOTICE,
        warning   => LOG_WARNING,
        warn      => LOG_WARNING,
        error     => LOG_ERR,
        err       => LOG_ERR,
        critical  => LOG_CRIT,
        crit      => LOG_CRIT,
        fatal     => LOG_CRIT,
        alert     => LOG_ALERT,
        emergency => LOG_EMERG,
    }->{$method};
    defined($priority) or $priority = LOG_ERR; # unknown, take a guess.

    make_method($method, sub { shift; syslog($priority, '%s', join('', @_)) });
}

# Create detection methods: is_debug, is_info, etc.
my $always_on = sub { 1; };
foreach my $method (Log::Any->detection_methods()) {
    make_method($method, $always_on);
}


1;

__END__

=head1 SYNOPSIS

    use Log::Any::Adapter;
    Log::Any::Adapter->set('Syslog');

    # You can override defaults:
    use Unix::Syslog qw{:macros};
    Log::Any::Adapter->set(
        'Syslog',
        # name defaults to basename($0)
        name     => 'my-name',
        # options default to LOG_PID
        options  => LOG_PID|LOG_PERROR,
        # facility defaults to LOG_LOCAL7
        facility => LOG_LOCAL7
    );

=head1 DESCRIPTION

L<Log::Any> is a generic adapter for writing logging into Perl modules; this
adapter use the L<Unix::Syslog> module to direct that output into the standard
Unix syslog system.

=head1 CONFIGURATION

C<Log::Any::Adapter::Syslog> is designed to work out of the box with no
configuration required; the defaults should be reasonably sensible.

You can override the default configuration by passing extra arguments to the
C<Log::Any::Adapter> method:

=over

=item name

The I<name> argument defaults to the basename of C<$0> if not supplied, and is
inserted into each line sent to syslog to identify the source.

=item options

The I<options> configure the behaviour of syslog; see L<Unix::Syslog> for
details.

The default is C<LOG_PID>, which includes the PID of the current process after
the process name:

    example-process[2345]: something amazing!

The most likely addition to that is C<LOG_PERROR> which causes syslog to also
send a copy of all log messages to the controlling terminal of the process.

B<WARNING:> If you pass a defined value you are setting, not augmenting, the
options.  So, if you want C<LOG_PID> as well as other flags, pass them all.

=item facility

The I<facility> determines where syslog sends your messages.  The default is
C<LOCAL7>, which is not the most useful value ever, but is less bad that
assuming the fixed facilities.

See L<Unix::Syslog> and L<syslog(3)> for details on the available facilities.

=back

=head1 AUTHORS

=over

=item Daniel Pittman <daniel@rimspace.net>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Daniel Pittman <daniel@rimspace.net>

Log::Any::Adapter::Syslog is provided "as is" and without any express or
implied warranties, including, without limitation, the implied warranties of
merchantibility and fitness for a particular purpose.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
