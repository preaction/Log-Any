package Log::Any::Manager::Base;
use strict;
use warnings;

sub get_logger {
    my ( $self, %params ) = @_;
    my $category = delete( $params{'category'} );
    if ( !defined($category) ) {
        $category = caller();
    }
    return $self->_get_logger_for_category($category);
}

1;
