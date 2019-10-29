package Log::Any::Adapter::Multiplex;

# ABSTRACT: Adapter to use allow structured logging across other adapters
# VERSION

use List::Util qw(any);
use Log::Any;
use Log::Any::Adapter;
use Log::Any::Adapter::Util qw(make_method);
use Log::Any::Manager;
use Log::Any::Proxy;
use Carp;
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

sub init {
    my $self = shift;

    my $adapters_and_args = $self->{adapters_and_args};
    if ( ( ref($adapters_and_args) ne 'HASH' ) ||
         ( grep { ref($_) ne 'ARRAY' } values %$adapters_and_args ) ) {
        Carp::croak("A list of adapters and their arguments must be provided");
    }
}

sub structured {
    my ($self, $level, $category, @structured_log_args) = @_;
    my %adapters_and_args = %{ $self->{adapters_and_args} };
    my $unstructured_log_args;

    for my $adapter ( $self->_get_adapters($category) ) {
        my $is_level = "is_$level";

        if ($adapter->$is_level) {
            # Very simple mimicry of Log::Any::Proxy
            # We don't have to handle anything but the difference in
            # non-structured interfaces
            if ($adapter->can('structured')) {
                $adapter->structured($level, $category, @structured_log_args)
            }
            else {
                if (!$unstructured_log_args) {
                    $unstructured_log_args = [
                        _unstructured_log_args( @structured_log_args )
                    ];
                }
                $adapter->$level(@$unstructured_log_args);
            }
        }
    }
}

sub _unstructured_log_args {
    my @structured   = @_;
    my @unstructured = @structured;

    if ( @structured && ( ( ref $structured[-1] ) eq ref {} ) ) {
        @unstructured = (
            @structured[ 0 .. $#structured - 1 ],
            Log::Any::Proxy::_stringify_params( $structured[-1] ),
        )
    }
    return @unstructured;
}

# Delegate detection methods to other adapters
#
foreach my $method ( Log::Any->detection_methods() ) {
    make_method(
        $method,
        sub {
            my ($self) = @_;
            return any { $_->$method } $self->_get_adapters();
        }
    );
}

sub _get_adapters {
    my ($self) = @_;
    my $category = $self->{category};
    # Log::Any::Manager#get_adapter has similar code
    # But has to handle rejiggering the stack
    # And works with one adapter at a time (instead of a list, as below)
    # Keeping track of multiple categories here is just future-proofing.
    #
    my $category_cache = $self->{category_cache};
    if ( !defined( $category_cache->{$category} ) ) {
        my $new_cache = [];
        my %adapters_and_args = %{ $self->{adapters_and_args} };
        while ( my ($adapter_name, $adapter_args) = each %adapters_and_args ) {
            my $adapter_class = Log::Any::Manager->_get_adapter_class($adapter_name);
            push @$new_cache, $adapter_class->new(
                @$adapter_args,
                category => $category
            );
        }

        $self->{category_cache}{$category} = $new_cache;
    }

    return @{ $self->{category_cache}{$category} };
}

1;
