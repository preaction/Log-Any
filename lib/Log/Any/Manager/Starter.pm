package Log::Any::Manager::Starter;
use Log::Any::Util qw(make_method);
use strict;
use warnings;
use base qw(Log::Any::Manager::Base);

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->{adapter_class}  = 'Log::Any::Adapter::Null';
    $self->{adapter_params} = {};
    return $self;
}

sub upgrade_to_full {
    my ($self) = @_;

    my $full_class = "Log::Any::Manager::Full";
    unless ( defined( eval "require $full_class" ) ) {
        die
          "error loading $full_class - do you have Log-Any-Adapter installed? - $@";
    }
    bless( $self, $full_class );
}

foreach my $method (qw(set_adapter set_adapter_for remove_adapter)) {
    make_method(
        $method,
        sub {
            my $self = shift;
            $self->upgrade_to_full();
            return $self->$method(@_);
        }
    );
}

1;
