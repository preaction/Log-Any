package Log::Any;
our $VERSION = '1.999_000';
# ABSTRACT: Fast logging that plays well with others

=head1 SYNOPSIS

    ### Basic use
    # Get a logger that logs to STDERR
    use Log::Any;
    my $log = Log::Any->new;

    # Shortcut
    use Log::Any qw( $log );

    # Log levels
    $log->info( "Informational" );
    $log->debug( "Debugging" );
    $log->warn( "Warning" );
    $log->error( "Error!" );
    $log->fatal( "Fatal!" );

    ### CPAN Modules / Opt-in logging
    # Get a logger that is silent (logs go nowhere) by default
    use Log::Any::Proxy;
    my $log = Log::Any::Proxy->new;
    if ( $log->is_silent ) {
        warn "Load Log::Any to see my logging!\n";
    }

    # Shortcut
    use Log::Any::Proxy qw( $log );
    # Make any silent loggers log to Stderr
    use Log::Any;
    if ( !$log->is_silent ) {
        say "Now I don't feel lonely!";
    }

    ### Log to Syslog
    use Log::Any -syslog;

    ### Log to Stderr, Syslog, and a file
    use Log::Any -stderr, -syslog, -file => 'debug.log';

    ### Log to Log4perl
    use Log::Any -log4perl;
    # With a config file
    use Log::Any -log4perl => 'log4perl.properties';

    ### Add a log destination
    use Log::Any qw( $log );
    $log->to( -file => 'debug.log' );

    # Add a log destination for one run
    perl -MLog::Any=-file,debug.log script.pl

    ### Get a scoped log object
    my $scoped_log = $log->scope;
    # Add contextual information
    $scoped_log->context( id => 'request id' );
    # Shortcut
    my $scoped_log = $log->scope( id => 'request id' );
    # Log this scope to a file
    $scoped_log->to( -file => 'debug.log' );

    ### Logging
    # Log conditionally
    $log->debug( sub { "A wall of text" );

    # Log with formatting
    $log->debugf( "An object: %s", $object );

    # Log conditionally with formatting
    $log->debugf( sub { "An object: %s", $object } );

    # Log and exit non-zero. Something is displayed even if silent or logs are redirected.
    die $log->fatal( "Goodbye" );
    # Log and warn. Something is displayed even if silent or logs are redirected.
    warn $log->warn( "I feel asleep!" );
    # Log and print. Something is displayed even if silent or logs are redirected.
    say $log->info( "Hello new friend!" );

    ### Log output
    # Regular log messages
    use Log::Any qw( $log );        # ??? Should timestamp?
    $log->info( "Hello" );          # [info] Hello
    $log->warn( "Uh-oh" );          # [warn] Uh-oh
    die $log->fatal( "Oh no!" );    # [fatal] Oh no!
                                    # Oh no! at script.pl line 4.
    # Show stack traces
    use Log::Any -trace, qw( $log );
    $log->info( "Hello" );          # [info] Hello at script.pl line 2.
    $log->warn( "Uh-oh" );          # [warn] Uh-oh at script.pl line 3.
    die $log->fatal( "Oh no!" );    # [fatal] Oh no! at script.pl line 4.
                                    # Oh no! at script.pl line 4.
    # Enable traces for one run
    perl -MLog::Any=-trace script.pl

    # With context
    use Log::Any qw( $log );
    $log->context( REMOTE_ADDR => '127.0.0.1' );            # ??? What must be supported in tag names/values?
    $log->info( "There's no place like" );                  # [info] There's no place like REMOTE_ADDR=127.0.0.1
    $log->infof( "We're not in %s, anymore", "Kansas" );    # [info] We're not in Kansas, anymore REMOTE_ADDR=127.0.0.1

=head1 DESCRIPTION

=head2 Changes From v1

=over 4

=item Loading Log::Any logs to C<STDERR> by default

If you want your module to create logs that can be enabled by a consuming application later,
change C<use Log::Any> in your module to C<use Log::Any::Proxy>.

=item Log::Any v2 requires Perl 5.24

=item Log::Any v2 requires non-core modules

This may be relaxed later, but L<Devel::StackTrace> is required.

=back

=head1 SEE ALSO

=cut

use v5.20;
use warnings;
use base 'Log::Any::Proxy';

=sub import

=cut

sub import {
    my ( $class, @args ) = @_;
}

1;
