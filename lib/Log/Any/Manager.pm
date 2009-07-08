package Log::Any::Manager;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    bless $self, $class;
    $self->use_logger('Null');
    return $self;
}

sub use_logger {
    my ( $$self, $adapter_name, %adapter_params ) = @_;

    my $adapter_class = "Log::Any::Adapter::$adapter_name";
    $self->{adapter_class}  = $adapter_class;
    $self->{adapter_params} = \%adapter_params;
    eval "require $adapter_class";
    die $@ if $@;
    $self->{category_matters} = $adapter_class->category_matters;

    # Replace each adapter out in the wild by reblessing and overriding hash
    #
    $self->{adapter_cache} ||= {};
    while ( my ( $category, $adapter ) = each( %{ $self->{adapter_cache} } ) ) {
        my $new_adapter =
          $adapter_class->new( %adapter_params, category => $category );
        %$adapter = %$new_adapter;
        bless( $adapter, $adapter_class );
    }
}

sub get_logger {
    my ( $self, %params ) = @_;

    my $category;
    if ( $self->{category_matters} ) {

        # Get category from params or from caller package
        #
        $category = delete( $params{'category'} );
        if ( !defined($category) ) {
            $category = caller();
        }
    }
    else {
        $category = 'Default';
    }

    # Create a new adapter for this category if it is not already in cache
    #
    my $adapter = $self->{adapter_cache}->{$category};
    if ( !defined($adapter) ) {
        $adapter =
          $self->{adapter_class}
          ->new( @{ $self->{adapter_params} }, category => $category );
        $self->{adapter_cache}->{$category} = $adapter;
    }
    return $adapter;
}

1;
