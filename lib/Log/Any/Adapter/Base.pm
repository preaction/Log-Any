use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Base;

our $VERSION = '1.051';
our @CARP_NOT = ( 'Log::Any::Adapter' );

# we import these in case any legacy adapter uses them as class methods
use Log::Any::Adapter::Util qw/make_method dump_one_line/;

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->init(@_);
    return $self;
}

sub init { }

# Create stub logging methods
for my $method ( Log::Any::Adapter::Util::logging_and_detection_methods() ) {
    no strict 'refs';
    *$method = sub {
        my $class = ref( $_[0] ) || $_[0];
        die "$class does not implement $method";
    };
}

# This methods installs a method that delegates to an object attribute
sub delegate_method_to_slot {
    my ( $class, $slot, $method, $adapter_method ) = @_;

    make_method( $method,
        sub { my $self = shift; return $self->{$slot}->$adapter_method(@_) },
        $class );
}

1;
