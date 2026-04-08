use strict;
use warnings;
use Test::More tests => 1;

use Log::Any::Adapter;
use Log::Any qw( $log );
use Log::Any::Adapter::Util;

use FindBin;
use lib $FindBin::RealBin;
use TestAdapters;

sub create_normal_log_lines {
    my ($log) = @_;

    $log->info('(info) some info');
    $log->infof( '(infof) more %s', 'info' );
    $log->infof( '(infof) info %s %s', { with => 'data' }, 'and more text' );
    $log->debug( '(debug) program started',
        { progname => 'foo.pl', pid => 1234, perl_version => '5.20.0' } );
    return;
}

Log::Any::Adapter->set('+TestAdapters::Structured');

push @{ $log->hooks->{'context'} }, \&build_context;
create_normal_log_lines($log);
pop @{ $log->hooks->{'build_context'} };

sub build_context {
    my ($lvl, $cat, $data) = @_;
    $data->{lvl} = $lvl;
    $data->{cat} = $cat;
    $data->{n}    = 1;
    return;
}

is_deeply(
    \@TestAdapters::STRUCTURED_LOG,
    [
        { messages => ['(info) some info'], level => 'info', category => 'main',
            data => [ {
                  'cat' => 'main',
                  'lvl' => 'info',
                  'n' => 1,
                }],
        },
        { messages => ['(infof) more info'], level => 'info', category => 'main',
            data => [ {
                  'cat' => 'main',
                  'lvl' => 'info',
                  'n' => 1,
                }],
        },
        { messages => ['(infof) info {with => "data"} and more text'],
          level    => 'info',
          category => 'main',
          data     => [
              {
                  'cat' => 'main',
                  'lvl' => 'info',
                  'n' => 1,
              },
          ],
        },
        {   messages => ['(debug) program started'],
            level    => 'debug',
            category => 'main',
            data     => [
                {
                    perl_version => '5.20.0', progname => 'foo.pl', pid => 1234,
                  'cat' => 'main',
                  'lvl' => 'debug',
                  'n' => 1,
                }
                ]
        },
    ],
    'identical output of normal log lines when using structured log adapter'
    );
