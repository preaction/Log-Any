package Log::Any::Manager::Base;
use Log::Any::Adapter::Null;
use strict;
use warnings;
use base qw(Log::Any::Manager::Base);

sub get_logger {
    my ( $self, %params ) = @_;
    my $category = delete( $params{'category'} );
    if ( !defined($category) ) {
        $category = caller();
    }

    # Create a new adapter for this category if it is not already in cache
    #
    my $adapter = $self->{adapter_cache}->{$category};
    if ( !defined($adapter) ) {
        $adapter =
          $self->{adapter_class}
          ->new( %{ $self->{adapter_params} }, category => $category );
        $self->{adapter_cache}->{$category} = $adapter;
    }
    return $adapter;
}

1;
