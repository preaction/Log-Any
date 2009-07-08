package Log::Any::Adapter::Base;
use Carp qw(croak);
use strict;
use warnings;

sub new {
    my ($class) = @_;
    my $self = {@_};
    bless $self, $class;
    $self->init();
    return $self;
}

sub init { }
sub category_matters { 0 }

sub delegate_method_to_slot {
    my ( $class, $slot, $method, $adapter_method ) = @_;

    no strict 'refs';
    *{"$class::$method"} =
      sub { my $self = shift; return $self->{$slot}->$adapter_method(@_) };
}

sub logging_methods {
    my $class = shift;
    return qw(debug, info, notice, warning, error, critical, alert, emergency);
}

sub detection_methods {
    my $class = shift;
    return map { "is_$_" } $class->logging_methods();
}

sub required_methods {
    my $class = shift;
    return ( $class->logging_methods, $class->detection_methods );
}

1;
