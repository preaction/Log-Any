use strict;
use warnings;
use Test::More;

our @TEXT_LOG;
our @STRUCTURED_LOG;

package MyApp::Log::Normal;
use base qw(Log::Any::Adapter::Base);
foreach my $method ( Log::Any->logging_methods() ) {
    no strict 'refs';
    *$method = sub { push @main::TEXT_LOG, $_[1] };
}
foreach my $method ( Log::Any->detection_methods() ) {
    no strict 'refs';
    *$method = sub { 1 };
}

package MyApp::Log::Structured;
use base qw(Log::Any::Adapter::Base);

sub structured {
    my ( $self, $level, $category, @args ) = @_;

    my ( $messages, $data );
    for (@args) {
        if (ref) {
            push @$data, $_;
        }
        else {
            push @$messages, $_;
        }
    }
    my $log_hash = { level => $level, category => $category };
    $log_hash->{messages} = $messages if $messages;
    $log_hash->{data}     = $data     if $data;
    push @STRUCTURED_LOG, $log_hash;
}

foreach my $method ( Log::Any->detection_methods() ) {
    no strict 'refs';
    *$method = sub { 1 };
}

package main;
use Log::Any::Adapter;

sub create_normal_log_lines {
    my ($log) = @_;

    $log->info('some info');
    $log->infof( 'more %s', 'info' );
    $log->infof( 'info %s %s', { with => 'data' }, 'and more text' );
    $log->debug( "program started",
        { progname => "foo.pl", pid => 1234, perl_version => "5.20.0" } );

}

Log::Any::Adapter->set('+MyApp::Log::Normal');
my $log = Log::Any->get_logger;
create_normal_log_lines($log);

Log::Any::Adapter->set('+MyApp::Log::Structured');
$log = Log::Any->get_logger;
create_normal_log_lines($log);
$log->info(
    'text',
    { and => [ 'structured', 'data', of => [ arbitrary => 'depth' ] ] },
    'and some more text'
);

is_deeply(
    \@TEXT_LOG,
    [
        "some info",
        "more info",
        "info {with => \"data\"} and more text",
        "program started {perl_version => \"5.20.0\",pid => 1234,progname => \"foo.pl\"}"
    ],
    'text log correct'
);

is_deeply(
    \@STRUCTURED_LOG,
    [
        { messages => ['some info'], level => 'info', category => 'main' },
        { messages => ['more info'], level => 'info', category => 'main' },
        {
            messages => ['info {with => "data"} and more text'],
            level    => 'info',
            category => 'main'
        },
        {
            messages => ['program started'],
            level    => 'debug',
            category => 'main',
            data     => [
                { perl_version => "5.20.0", progname => "foo.pl", pid => 1234 }
            ]
        },
        {
            messages => [ 'text', 'and some more text' ],
            data     => [
                {
                    and => [
                        'structured', 'data', of => [ arbitrary => 'depth' ]
                    ]
                }
            ],
            level    => 'info',
            category => 'main'
        }
    ],
    'identical output of normal log lines when using structured log adapter'
);

done_testing;
