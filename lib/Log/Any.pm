package Log::Any;
use 5.006;
use Carp qw(croak);
use Log::Any::Manager;
use Log::Any::Util qw(dp);
use strict;
use warnings;

our $VERSION = '0.01';

my $Manager = Log::Any::Manager->new();

sub import {
    my $class  = shift;
    my $caller = caller();

    my @export_params = ( $caller, @_ );
    $class->_export_to_caller(@export_params);
}

sub _export_to_caller {
    my $class  = shift;
    my $caller = shift;

    # Parse parameters passed to 'use Log::Any'
    #
    my @vars;
    foreach my $param (@_) {
        if ( substr( $param, 0, 1 ) eq '$' ) {
            push( @vars, $param );
        }
        else {
            croak $class->_invalid_import_error($param);
        }
    }

    # Import requested variables into caller
    #
    foreach my $var (@vars) {
        my $value;
        if ( $var eq '$log' ) {
            $value = $class->get_logger( category => $caller );
        }
        else {
            croak $class->_invalid_import_error($var);
        }
        my $no_sigil_var = substr( $var, 1 );
        no strict 'refs';
        *{"$caller\::$no_sigil_var"} = \$value;
    }
}

sub _invalid_import_error {
    my ( $class, $param ) = @_;

    die "invalid import '$param' - valid imports are '\$log'";
}

sub set_adapter {
    my $class = shift;
    $Manager->set_adapter(@_);
}

sub get_logger {
    my ( $class, %params ) = @_;
    $Manager->get_logger( category => scalar( caller() ), %params );
}

sub logging_methods {
    my $class = shift;
    return qw(debug info notice warning error critical alert emergency);
}

sub detection_methods {
    my $class = shift;
    return map { "is_$_" } $class->logging_methods();
}

sub logging_and_detection_methods {
    my $class = shift;
    my @list = ( $class->logging_methods, $class->detection_methods );
    return @list;
}

sub log_level_aliases {
    my $class = shift;
    return (
        inform => 'info',
        warn   => 'warning',
        err    => 'error',
        crit   => 'critical',
        fatal  => 'critical'
    );
}

1;

__END__

=pod

=head1 NAME

Log::Any -- Log anywhere

=head1 SYNOPSIS

In a CPAN or other module:

    package Foo;
    use Log::Any qw($log);

    $log->error("an error occurred");
    $log->debugf("arguments are: %s", \@_)
        if $log->is_debug();

In your application:

    use Log::Any;

    # Choose a logging mechanism:

    use Log::Log4perl;
    Log::Log4perl::init('/etc/log4perl.conf');
    Log::Any->set_adapter('Log::Log4perl');

    # or

    use Log::Dispatch;
    my $dispatcher = Log::Dispatch->new();
    $dispatcher->add(...);
    Log::Any->set_adapter('Log::Dispatch', dispatcher => $dispatcher);

    # or

    use Log::Dispatch::Config;
    Log::Dispatch::Config->configure('/path/to/log.conf');
    Log::Any->set_adapter('Log::Dispatch');

    # or

    use Log::Tiny;
    my $log = Log::Tiny->new('myapp.log');
    Log::Any->set_adapter('Log::Tiny', log => $log);

=head1 DESCRIPTION

Log::Any provides a facility for CPAN modules to safely and efficiently log
messages, while leaving the choice of logging mechanism to the application.

=head1 BACKGROUND

Many modules have something interesting to say. Unfortunately, there is no
standard way for them to say it - some output to STDERR, others to warn, others
to L<Log::Dispatch|Log::Dispatch>. And there is no standard way to get a module
to start talking - sometimes you must call a uniquely named method, other times
set a package variable.

This being Perl, there are many logging mechanisms available on CPAN:
L<Log::Log4perl|Log::Log4perl>, L<Log::Dispatch|Log::Dispatch>,
L<Log::Tiny|Log::Tiny>, etc.  Each has their pros and cons. Unfortunately, the
existence of so many mechanisms makes it difficult for a CPAN author to commit
his/her users to one of them.  This may be why many CPAN modules invent their
own logging or choose not to log at all.

To untangle this situation, we must acknowledge the two parts of a logging API.
The first, I<log production>, includes methods to output logs (like
C<$log-E<gt>debug>) and methods to inspect whether a log level is activated
(like C<$log-E<gt>is_debug>). This is generally all that CPAN modules care
about. The second, I<log consumption>, includes a way to configure where
logging goes (a file, the screen, etc.) and the code to send it there. This
choice generally belongs to the application.

Log::Any provides a standard log production API for modules, and allows
applications to choose the mechanism for log consumption.  It supports a
standard set of log levels (e.g. as used by syslog) and log categories (e.g. as
used by log4perl). It defaults to 'null' logging activity, so that a module can
safely start logging without worrying about whether the application has
initialized a logging mechanism.

=head1 LOG LEVELS

Every logging mechanism on CPAN uses a slightly different set of levels. For
Log::Any we've standardized on the log levels from syslog, and also added a
number of common aliases:

     debug
     info (inform)
     notice
     warning (warn)
     error (err)
     critical (crit, fatal)
     alert
     emergency

Levels are translated as appropriate to the underlying logging mechanism. For
example, log4perl only has five levels, so we translate 'notice' to 'info' and
the top three levels to 'fatal'.

=head1 CATEGORIES

Every logger has a category, generally the name of the class that asked for the
logger. With the notable exception of log4perl, most logging mechanisms don't
care about categories, so they will just be ignored. That said, category-based
logging is very powerful and it would be nice if more mechanisms supported it.

=head1 ADAPTERS

In order to use a logging mechanism with Log::Any, there needs to be an adapter
class for it. Typically this is under Log::Any::Adapter::I<module-name>. The
following adapters are available as of this writing:

=over

=item *

L<Log::Any::Adapter::Log::Log4perl> - work with log4perl

=item *

L<Log::Any::Adapter::Log::Dispatch> - work with Log::Dispatch

=item *

L<Log::Any::Adapter::Log::Dispatch::Config> - work with Log::Dispatch::Config

=item *

L<Log::Any::Adapter::Log::Tiny> - work with Log::Tiny

=item *

L<Log::Any::Adapter::Null> - logs nothing - the default

=back

This list may be incomplete. A complete set of adapters can be found on CPAN by
searching for "Log::Any::Adapter".

See L<Log::Any::Adapter::Development> for information on developing new
adapters.

=head1 PRODUCING LOGS (FOR MODULES)

=head2 Getting a logger

The most convenient way to get a logger in your module is:

    use Log::Any qw($log);

This creates a package variable $log and assigns it to the logger for the
current package. It is equivalent to

    our $log = Log::Any->get_logger(category => __PACKAGE__);

In general, to get a logger for a specified category:

    my $log = Log::Any->get_logger(category => $category)

If no category is specified, the caller package is used.

=head2 Logging

To log a message, use any of the log levels or aliases. e.g.

    $log->error("this is an error");
    $log->warn("this is a warning");
    $log->warning("this is also a warning");

You should B<not> include a newline in your message; that is the responsibility
of the logging mechanism, which may or may not want the newline.

There are also printf-style versions of each of these methods:

    $log->errorf("an error occurred: %s", $@);
    $log->debugf("called with %d params: %s", $param_count, \@params);

The printf-style methods have a few advantages. First, they can be more
readable than concatenated strings (subjective of course); second, any complex
references (like C<\@params> above) are automatically converted to strings with
Data::Dumper; third, a logging mechanism could potentially hash the format
string to a unique id, e.g. to group related log messages together.

=head2 Log level detection

To detect whether a log level is on, use "is_" followed by any of the log
levels or aliases. e.g.

    if ($log->is_info()) { ... }
    $log->debug("arguments are: " . Dumper(\@_))
        if $log->is_debug();

This is important for efficiency, as you can avoid the work of putting together
the logging message (in the above case, stringifying C<@_>) if the log level is
not active.

Some logging mechanisms don't support detection of log levels - e.g.
L<Log::Tiny|Log::Tiny>.  In these cases the detection methods will always
return 1.

In contrast, the default logging mechanism - Null - will return 0 for all
detection methods.

=head1 CONSUMING LOGS (FOR APPLICATIONS)

=head2 Choosing an adapter

Initially, all C<Log::Any> logs are discarded (via the Null adapter). If you
want the logs to go somewhere, you need to select an adapter with set_adapter,
e.g.:

    # Use Log::Log4perl
    Log::Log4perl::init('/etc/log4perl.conf');
    Log::Any->set_adapter('Log::Log4perl');

    # Use Log::Dispatch
    my $dispatcher = Log::Dispatch->new();
    $dispatcher->add(...);
    Log::Any->set_adapter('Log::Dispatch', dispatcher => $dispatcher);

The first argument to C<set_adapter> is the name of an adapter. It is
automatically prepended with "Log::Any::Adapter::". If instead you want to pass
the full name of an adapter, prefix it with a "+". e.g.

    # Use My::Adapter class
    Log::Any->set_adapter('+My::Adapter', ...);

The remaining arguments are passed along to the adapter constructor. See the
documentation for the individual adapter classes for more information.

C<set_adapter> can be called multiple times; the last call overwrites any
previous calls. In fact, C<set_adapter> is automatically called once with
'Null' at startup, so every call you make will be an overwrite.

When you call C<set_adapter>, any Log::Any loggers that have previously been
created (with C<use Log::Any qw($log)> or with C<Log::Any-E<gt>get_logger>)
will automatically be converted to the new adapter. This allows modules to
freely create and use loggers without worrying about when (or if) the
application is going to set an adapter. For example:

    my $log = Log::Any->get_logger();
    $log->error("aiggh!");   # this goes nowhere
    ...
    Log::Any->set_adapter('Log::Log4perl');
    $log->error("aiggh!");   # this goes to log4perl
    ...
    Log::Any->set_adapter('Null');
    $log->error("aiggh!");   # this goes nowhere again

There is no way to set more than one adapter at a time. If you want to log to
more than one place, arrange that through the logging mechanism (e.g.
L<Log::Dispatch|Log::Dispatch> and L<Log::Log4perl|Log::Log4perl> both make
this easy).

=head1 AUTHOR

Jonathan Swartz

=head1 SEE ALSO

L<Some::Module>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2007 Jonathan Swartz.

Log::Any is provided "as is" and without any express or implied warranties,
including, without limitation, the implied warranties of merchantibility and
fitness for a particular purpose.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
