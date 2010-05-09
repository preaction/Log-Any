package Log::Any::Adapter::Syslog;
use strict;
use warnings;

use Log::Any::Adapter::Util qw{make_method};
use base qw{Log::Any::Adapter::Base};

use Unix::Syslog qw{:macros :subs};
use File::Basename ();

# Optionally initialize object
#
sub init {
    my ($self) = @_;
    return if $self->{opened};

    $self->{name} ||= File::Basename::basename($0);
    $self->{name} ||= 'perl';

    $self->{options}  ||= LOG_PID;
    $self->{facility} ||= LOG_LOCAL7;

    warn "$self->{name}, $self->{options}, $self->{facility}";
    openlog($self->{name}, $self->{options}, $self->{facility});

    $self->{opened} = 1;
    return $self;
}

# Create logging methods: debug, info, etc.
#
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
    $priority ||= LOG_ERR;      # unknown, take a guess.

    make_method($method, sub { shift; syslog($priority, shift, @_) });
}

# Create detection methods: is_debug, is_info, etc.
#
my $always_on = sub { 1; };
foreach my $method (Log::Any->detection_methods()) {
    make_method($method, $always_on);
}


1;

=pod

=encoding utf8

=head1 NAME

Log::Any::Adapter::Syslog - send Log::Any logs to syslog

=head1 SYNOPSIS

    use Log::Any::Adapter;
    Log::Any::Adapter->set('Syslog');

    # You can override defaults:
    use Unix::Syslog qw{:macros};
    Log::Any::Adapter->set('Syslog', 'my-name', LOG_PID|LOG_PERROR, LOG_LOCAL7);

    # Passing undef as the name gets the default, which this is:
    Log::Any::Adapter->set('Syslog', undef, LOG_PID);

=head1 DESCRIPTION

L<Log::Any> is a generic adapter for writing logging into Perl modules; this
adapter use the L<Unix::Syslog> module to direct that output into the standard
Unix syslog system.

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
