use strict;
use warnings;
use Test::More;

use Log::Any;
use Log::Any::Adapter;

{
    package _My::Structured::Adapter;
    use base 'Log::Any::Adapter::Base';
    use Log::Any::Adapter::Util qw(make_method);

    our $Instance;
    our $Is_Logging      = 0;
    our @Structured_Args = ();

    sub init { $Instance = shift }

    sub structured { @Structured_Args = @_ }
    foreach my $method ( Log::Any->detection_methods() ) {
        make_method( $method, sub { $Is_Logging } );
    }
}

{
    package _My::Unstructured::Adapter;
    use base 'Log::Any::Adapter::Base';
    use Log::Any::Adapter::Util qw(make_method);

    our $Instance;
    our $Is_Logging        = 0;
    our %Unstructured_Args = ();

    sub init { $Instance = shift }

    # Log what we called at each severity
    foreach my $method ( Log::Any->logging_methods() ) {
        make_method( $method, sub { $Unstructured_Args{$method} = [@_] } );
    }

    foreach my $method ( Log::Any->detection_methods() ) {
        make_method( $method, sub { $Is_Logging } );
    }
}

subtest basic_arg_validation => sub {
    # helpful for making sure init() is called on each set() below
    my $log = Log::Any->get_logger;

    eval { Log::Any::Adapter->set( 'Multiplex' ) };
    ok $@, 'adapters_and_args are required';

    eval {
        Log::Any::Adapter->set(
            'Multiplex',
            adapters_and_args => 'Stdout'
        )
    };
    ok $@, 'adapters_and_args must be a hash';

    eval {
        Log::Any::Adapter->set(
            'Multiplex',
            adapters_and_args => 'Stdout'
        )
    };
    ok $@, 'adapters_and_args must be a hash';

    eval {
        Log::Any::Adapter->set(
            'Multiplex',
            adapters_and_args => {
                Stdout => {}
            }
        )
    };
    ok $@, 'adapters_and_args values must be arrays';

    eval {
        Log::Any::Adapter->set(
            'Multiplex',
            adapters_and_args => {
                Stdout => [ log_level => 'info' ],
                Stderr => [],
            }
        )
    };
    ok !$@, "Multiplex set up as expected"
        or diag $@;
};

subtest multiplex_implementation => sub {
    my %Random_Args = ( log_level => 'scream' );

    my $entry = Log::Any::Adapter->set(
        'Multiplex',
        adapters_and_args => {
            '+_My::Structured::Adapter'   => [ %Random_Args ],
            '+_My::Unstructured::Adapter' => [ %Random_Args ],
        }
    );

    my $log = Log::Any->get_logger();
    ok !$log->is_info, "multiplex logging off for both destinations";

    $_My::Structured::Adapter::Is_Logging   = 1;
    $_My::Unstructured::Adapter::Is_Logging = 0;
    ok $log->is_info, "multiplex logging on for one destination";

    $_My::Structured::Adapter::Is_Logging   = 0;
    $_My::Unstructured::Adapter::Is_Logging = 1;
    ok $log->is_info, "multiplex logging on for other destination";

    $_My::Structured::Adapter::Is_Logging   = 1;
    $_My::Unstructured::Adapter::Is_Logging = 1;
    ok $log->is_info, "multiplex logging on for both destinations";

    my $structured_adapter   = $_My::Structured::Adapter::Instance;
    my $unstructured_adapter = $_My::Unstructured::Adapter::Instance;

    is $structured_adapter->{log_level},
       $Random_Args{log_level},
       "Arguments passed to structured adapter";
    is $unstructured_adapter->{log_level},
       $Random_Args{log_level},
       "Arguments passed to unstructured adapter";

    my $Message = "In a bottle";
    my $Level   = 'info';
    my $Cat     = __PACKAGE__;
    $log->context->{foo} = 'bar';
    my $Ctx_Str = '{foo => "bar"}';
    $log->$Level($Message);

    is_deeply [ @_My::Structured::Adapter::Structured_Args ],
              [ $structured_adapter, $Level, $Cat, $Message, $log->context ],
              "Passed appropriate structured args";
    is_deeply $_My::Unstructured::Adapter::Unstructured_Args{$Level},
              [ $unstructured_adapter, $Message, $Ctx_Str ],
              "Passed appropriate unstructured args";

    @_My::Structured::Adapter::Structured_Args = ();
    $_My::Structured::Adapter::Is_Logging = 0;
    $log->$Level($Message);
    is_deeply [ @_My::Structured::Adapter::Structured_Args ],
              [ ],
              "structured adapter not called when not logging";

    $_My::Structured::Adapter::Is_Logging = 1;
    %_My::Unstructured::Adapter::Unstructured_Args = ();
    $_My::Unstructured::Adapter::Is_Logging = 0;
    $log->$Level($Message);
    is_deeply { %_My::Unstructured::Adapter::Unstructured_Args },
              { },
              "unstructured adapter not called when not logging";
};

done_testing();
