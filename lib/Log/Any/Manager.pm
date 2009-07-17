package Log::Any::Manager;
use Carp;
use Log::Any::Util qw(require_dynamic);
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->set_adapter('Null');
    return $self;
}

sub set_adapter {
    my ( $self, $adapter_name, %adapter_params ) = @_;

    croak "adapter class required"
      unless defined($adapter_name) && $adapter_name =~ /\S/;
    $adapter_name =~ s/^Log:://;
    my $adapter_class = (
          substr( $adapter_name, 0, 1 ) eq '+'
        ? substr( $adapter_name, 1 )
        : "Log::Any::Adapter::$adapter_name"
    );
    $self->{adapter_class}  = $adapter_class;
    $self->{adapter_params} = \%adapter_params;
    require_dynamic($adapter_class);

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

