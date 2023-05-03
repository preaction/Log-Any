use strict;
use warnings;
use Test::More tests => 1;

use Log::Any::Adapter;
use Log::Any '$log';

use FindBin;
use lib $FindBin::RealBin;
use TestAdapters;

sub create_normal_log_lines {
    my ($log) = @_;

    $log->info('some info');
    $log->infof( 'more %s', 'info' );
    $log->infof( 'info %s %s', { with => 'data' }, 'and more text' );
    $log->debug( "program started",
        { progname => "foo.pl", pid => 1234, perl_version => "5.20.0" } );

}

Log::Any::Adapter->set('+TestAdapters::Structured');

push @{ $log->hooks->{'build_context'} }, \&build_context;
create_normal_log_lines($log);
pop @{ $log->hooks->{'build_context'} };

sub build_context {
    my ($lvl, $cat, $caller, $data) = @_;
    my %ctx;
    $ctx{lvl} = $lvl;
    $ctx{cat} = $cat;
    $ctx{file} = $caller->[1];
    $ctx{line} = $caller->[2];
    $ctx{n}    = 1;
    return %ctx;
}

is_deeply(
    \@TestAdapters::STRUCTURED_LOG,
    [
        { messages => ['some info'], level => 'info', category => 'main',
            data => [ {
                  'line' => 15,
                  'cat' => 'main',
                  'lvl' => 'info',
                  'file' => 't/hooks.t',
                  'n' => 1,
                }],
        },
        { messages => ['more info'], level => 'info', category => 'main',
            data => [ {
                  'line' => 16,
                  'cat' => 'main',
                  'lvl' => 'info',
                  'file' => 't/hooks.t',
                  'n' => 1,
                }],
        },
        { messages => ['info {with => "data"} and more text'],
          level    => 'info',
          category => 'main',
          data     => [
              {
                  'line' => 17,
                  'cat' => 'main',
                  'lvl' => 'info',
                  'file' => 't/hooks.t',
                  'n' => 1,
              },
          ],
        },
        {   messages => ['program started'],
            level    => 'debug',
            category => 'main',
            data     => [
                {
                    perl_version => "5.20.0", progname => "foo.pl", pid => 1234,
                  'line' => 18,
                  'cat' => 'main',
                  'lvl' => 'debug',
                  'file' => 't/hooks.t',
                  'n' => 1,
                }
                ]
        },
    ],
    'identical output of normal log lines when using structured log adapter'
    );
