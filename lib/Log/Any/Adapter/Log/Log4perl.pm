package Log::Any::Adapter::Log::Log4perl;
use Log4perl;
use Carp qw(croak);
use strict;
use warnings;

sub category_matters { 1 }

sub init {
    my ($self) = @_;

    $self->{logger} = Log::Log4perl->get_logger( $self->{category} );
}

# Delegate methods to logger, mapping levels down to log4perl levels where necessary
#
foreach my $method ( __PACKAGE__->logging_and_detection_methods() ) {
    my $log4perl_method = $method;
    for ($log4perl_method) {
        s/notice/info/;
        s/warning/warn/;
        s/critical|alert|emergency/fatal/;
    }
    __PACKAGE__->delegate_method_to_slot( 'logger', $method, $log4perl_method );
}

1;
